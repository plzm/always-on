# ALWAYS ON

![Infra-DeployGlobal](https://github.com/plzm/always-on/actions/workflows/infra.deploy.global.yml/badge.svg)
![Infra-DeployRegion](https://github.com/plzm/always-on/actions/workflows/infra.deploy.region.yml/badge.svg)
![Infra-ConfigRegion](https://github.com/plzm/always-on/actions/workflows/infra.config.region.yml/badge.svg)
![App-Deploy](https://github.com/plzm/always-on/actions/workflows/app.deploy.yml/badge.svg)

## SUMMARY

### SCOPE

This onboarding solution focuses on building highly performant and globally distributed (always-on) applications on Azure, leveraging popular and emerging native services such as the Azure Kubernetes Service (AKS) and Cosmos DB for a complete and end-to-end application deployment.

This is ultimately a full-stack engineering scenario, with participants working to define, build and configure a multi-region application landscape as well as developing a synthetic workload to optimise and validate the overall performance, availability, and security of the application.

### SCENARIO

The hypothetical scenario for this onboarding solution considers a simple web service for a video game to track player progression. More specifically it offers a global API surface for clients to both retrieve and 'upsert' player progression metrics.
 
The system must be highly performant with minimal response times at high request volumes to ensure core player experiences are not impacted, and must also achieve global consistency to ensure multiple clients connecting from across the globe receive an accurate view of player data.

### TARGETS (NFRs)

The following list provides a guiding set of non-functional requirements which the established application must adhere to:

- Must be able to scale beyond 100,000tps.
- Must be highly performant with 99% of requests taking no more than 200ms.
- Must be highly resilient and support an availability target of greater than 99.99%.
- Must be globally available and capable of scaling to new regions with relative ease.

### ARCHITECTURE

The diagrams below provide an end-to-end composition of the target architecture, first as a single region deployment before expanding to consider multiple regions.

![Single-region architecture.](/media/images/arch1.png 'Single-region architecture')

![Multi-region architecture.](/media/images/arch2.png 'Multi-region architecture')

### STACK

- Azure Front Door: Used as a global load balancer to support a active global deployments across all considered regions. Offers optimised client connectivity using the anycast protocol with split TCP to take advantage of Microsoft’s global backbone network. It also provides WAF capabilities at the edge.
- API Management: Used to as an API gateway to publish and manage API components.
- Virtual Network: Private network used to house application components which can be deployed into a virtual network.
- DDoS Standard Plan: Provides additional DDoS protection mechanisms to secure the API surface and virtual network resources from malicious DDoS attacks.
- Network Security Group: Used to isolate the subnet encompassing application compute components from unintended access.
- Application Gateway WAF (v2): Leveraged to load balance application traffic across backend clusters within a region, as well as providing further intra-region WAF capabilities.
- Azure Kubernetes Services: Provides a scalable managed compute platform for the deployment and management of containerised application components
- CosmosDB: Provides a highly scalable global data platform for persisting player progression metrics. A multi-master deployment pattern will be used to support regional performance and global consistency targets.
- Event Hub: provides a high throughput asynchronous messaging platform for the processing of longer running API calls.
- Azure Container Registry: Supports the secure and automated deployment of application containers through a securely managed private repository.
- Key Vault: Used to house certificates and application secrets.
- Azure DevOps: Provides integrated automation channels for application and infrastructure CI/CD pipelines.
- GitHub: Provides private git repositories for both application and infrastructure artefacts.

### WALK-THROUGH

- Client requests are routed by Front Door and API management to Application Gateway for distribution across AKS cluster(s) within the region to the FE API application component.
- The FE API should either interact directly with the CosmosDB for simple scenarios such as a get or should create a message on the regional Event Hub for subsequent processing.
- The BE Worker component should be established to read messages from the regional Event Hub and perform the necessary upsert actions against CosmosDB.

### APPROACH

#### LEVEL 1 - SINGLE REGION DEPLOYMENT

1. Templatise foundational resources (AKS, Event Hub, CosmosDB)  and deploy a single regional infrastructure stamp.
   1. Tasks 1.i, 1.iii
2. Create a containerised sample workload using .Net Core or a suitably justified alternative, storing code artefacts . The workload must suitably consider the walkthrough denoted above.
   1. Tasks 5.i-v
3. Optimise Cosmos access to ensure basic performance targets can be satisfied.
   1. Task 1.ii
4. Configure the AKS cluster for secure scale and deploy application containers via private repos
   1. Tasks 1.iii, 6.i-ii

#### LEVEL 2 - OPERATIONALISATION

1. Define CI/CD automation pipelines for both the application components and underlying Azure resources (IaC) using Azure DevOps. (Note, I am using Github Actions - GHA.)
   1. Tasks 3.i-iii, 4.i-iii, 6.i-ii
2. Operationalisation of application components through robust logging and the integration of all Azure resources with native tooling, such as Log Analytics and Application insights (and container insights).
   1. Tasks 7.i-iii
3. Define and surface a health model for the entire application, applying a 'traffic light' system to represent when the system is healthy
   1. Tasks 8.i-iii
4. Harden the security of the system and demonstrate its resilience to typical security risks, particularly DDoS vulnerabilities.
   1. Tasks 9.i-ii

#### LEVEL 3 - MULTI-REGION EXPANSION

1. Revise deployment pipelines to deploy at least two additional regional stamps in an active-active fashion
   1. Tasks 1.i-iii
2. Define an appropriate data consistency model based on scenario requirements, with multiple masters configured
   1. Task 1.ii
3. Identify and demonstrate critical failure scenarios throughout the entire application stack
   1. Tasks 10.i-iii
4. Runbook automation for the orchestration of failover scenarios
   1. Task 10.iv

#### LEVEL 4 - SHOW AND TELL

1. Demonstrate the application meets the performance and availability targets through extensive performance testing and sustained load testing during error and attack scenarios, including DDoS attacks (e.g. BreakingPoint Cloud) and failed AKS nodes.
   1. Tasks 11.i-iii

## TASKS

1. Infra automation
   1. Templatize each resource type.
   2. Global: one resource, configured for n Azure regions.
   3. Regional: one resource per Azure region.
2. Workflow
   1. Chart resource deployments: sequence, dependencies
3. CD Pipeline for Global Resources
   1. Determine trigger(s).
   2. For each resource, pass all Azure regions to template; configure within template
   3. Create/test GHA workflow. Outcome: successful deploy of global resources.
4. CD Pipeline(s) for Regional Resources
   1. Determine trigger(s).
   2. Determine how to deploy region n. GHA does not support iteration in workflow, so cannot set e.g. an array of regions. For now, each push = one region, as set in AZURE_REGION (or similar) env var?
   3. Create/test GHA workflows. Outcome: successful deploy of >1 Azure regions in succession.
5. APIs
   1. Create Front End (FE) and Back End (BE) APIs.
   2. FE API: Point reads from Cosmos DB. Writes to Event Hub.
   3. BE API: Read from Event Hub. Upsert to Cosmos DB.
   4. Consider two versions: 1. Minimal, with direct knowledge of CDB/EH. 2. Dapr-ified, so APIs do not need "direct knowledge". Potential for performance comparisons.
   5. Add container support / Dockerfiles.
6. CI/CD Pipelines for APIs
   1. CI on push. Build, test, Dockerize, push image to non-prod registry?
   2. CD on merge to main. Build, test, Dockerize, push image to prod registry, run AKS deploy for updated API.
7. Observability
   1. Configure resources to log to Log Analytics. Integrate into infra CD pipelines.
   2. Configure AKS for Container Insights. Integrate into infra CD pipelines.
   3. Configure APIs to log to App Insights.
8. Health Model
   1. Define metrics/alerts that constitute an aggregate health snapshot ("traffic light model")
   2. Determine how to surface/visualize this - an Azure Dashboard? Or third-party tooling (Grafana, Datadog, etc.)?
   3. Surface and test.
9. Security
   1. List security risks and controls/mitigations.
   2. Implement top mitigations. E.g. DDoS protection; network access restrictions; private networking; etc.
10. Continuity
    1. List possible failure scenarios.
    2. Demonstrate failure scenarios. Consider Chaos Studio?
    3. List failure mitigations.
    4. Automate failover actions/steps with Runbook as applicable.
11. Testing
    1. Implement distributed load test for DDoS and general perf evaluation.
    2. Implement perf test to gauge max throughput.
    3. Implement BreakingPoint DDoS test.

## STEPS

### 1. Prepare Secrets

Save the following secrets to the repo(s).

- ADMIN_USERNAME (used for AKS Nodes)
- AZURE_CREDENTIALS (used for workflow auth, see below)
- AZURE_SUBSCRIPTION_ID (used for various steps)
- AZURE_TENANT_ID (used for various steps)
- SSH_KEY (in form ssh-rsa [key]== username; used for AKS Nodes)

#### AZURE_CREDENTIALS

The SP for GHA should have Owner RBAC on the deployment RG so that role assignments (e.g. AKS cluster UAMI ---> VNet Network Contributor for kubenet config) will succeed.

Use these commands to create a SP and prep the JSON block:

``` bash
subscriptionId="$(az account show -o tsv --query 'id')" # This assumes your default sub is the one to use
spName="pz-always-on-deploy"
az ad sp create-for-rbac --name "$spName" --role owner --scopes "/subscriptions/""$subscriptionId" --sdk-auth
```

Copy the az ad sp create command output (or use az ad sp show later with --id {clientId}) and paste the whole JSON block into the secret. Example:

``` JSON
{
  "displayName": "{SP name}",
  "name": "http://{SP name}",
  "clientId": "{guid}",
  "clientSecret": "{guid}",
  "subscriptionId": "{guid}",
  "tenantId": "{guid}"
}
```

Powershell alternative:

``` Powershell
$servicePrincipal = New-AzADServicePrincipal -Role Contributor -Scope "/subscriptions/$subscriptionId" -DisplayName $spName

[ordered]@{
  clientId = $servicePrincipal.ApplicationId
  displayName = $servicePrincipal.DisplayName
  name = $servicePrincipal.ServicePrincipalNames[1]
  clientSecret = [System.Net.NetworkCredential]::new("", $servicePrincipal.Secret).Password
  tenantId = (Get-AzContext).Tenant.Id
  subscriptionId = (Get-AzContext).Subscription.Id
} | ConvertTo-Json
```

### 2. Tooling and Reference

#### Tooling

- VS Code with usual extensions for Azure deploy (ARM Tools etc.)
- Azure CLI
- kubectl - pre-installed in Cloud Shell, or install locally (WSL2) with `az aks install-cli` (may need to sudo)

#### Useful References

##### IaC

- [Azure CLI Reference](https://docs.microsoft.com/cli/azure/)
- [ARM Templates Reference](https://docs.microsoft.com/azure/templates/)
- [ARM Template Functions Reference](https://docs.microsoft.com/azure/azure-resource-manager/templates/template-functions/)

- [Azure VNet Service Tags](https://docs.microsoft.com/azure/virtual-network/service-tags-overview)
- [Azure Regions with AZs](https://docs.microsoft.com/azure/availability-zones/az-region#azure-regions-with-availability-zones)
- [Azure RBAC Built-in Roles](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles)

- [Tutorial: Enable AGIC for existing AKS, AppGW](https://docs.microsoft.com/azure/application-gateway/tutorial-ingress-controller-add-on-existing)
- [Install AGIC with existing AppGW](https://docs.microsoft.com/azure/application-gateway/ingress-controller-install-existing) (The tutorial on the preceding line is newer. This link includes obsolete steps but left here for reference.)
- [AGIC Tutorials](https://github.com/Azure/application-gateway-kubernetes-ingress/tree/master/docs/tutorials)
- [App Gateway Ingress Annotations](https://azure.github.io/application-gateway-kubernetes-ingress/annotations/)

- [Enable AKS Pod Identity](https://docs.microsoft.com/azure/aks/use-azure-ad-pod-identity)
- [Install AGIC on existing App GW](https://docs.microsoft.com/azure/application-gateway/ingress-controller-install-existing)
- [Understanding Ingress Controllers and AppGW pt1](https://roykim.ca/2020/02/09/understanding-ingress-controllers-and-azure-app-gateway-for-azure-kubernetes-part-1-intro/)
- [Understanding Ingress Controllers and AppGW pt2](https://roykim.ca/2020/02/16/understanding-ingress-controllers-and-azure-app-gateway-for-azure-kubernetes-part-2-agic/)
- [Advanced AKS Configuration](https://borzenin.com/azure-kubernetes-service-aks-workshop-2-labs/)

- [Integrate ACR and AKS](https://docs.microsoft.com/azure/aks/cluster-container-registry-integration)
- [Build a container image and deploy to AKS](https://docs.microsoft.com/azure/aks/kubernetes-action#build-a-container-image-and-deploy-to-azure-kubernetes-service-cluster)

- [Pod security in AKS, and accessing AKV with Secrets Store CSI Driver](https://docs.microsoft.com/azure/aks/developer-best-practices-pod-security#use-azure-key-vault-with-secrets-store-csi-driver)
- [Use AAD Pod Identity](https://docs.microsoft.com/azure/aks/use-azure-ad-pod-identity)
- [AAD Pod Identity for K8S Docs and Troubleshooting](https://azure.github.io/aad-pod-identity/docs/)
- [AAD Pod Identity github](https://github.com/Azure/aad-pod-identity)

- [AKV Provider for Secret Store CSI Driver](https://github.com/Azure/secrets-store-csi-driver-provider-azure)
- [AKV Provider for Secret Store CSI Driver Docs, Configurations, Troubleshooting](https://azure.github.io/secrets-store-csi-driver-provider-azure/configurations/identity-access-modes/pod-identity-mode/)
- [Secrets Store CSI Driver and Provider Docs](https://secrets-store-csi-driver.sigs.k8s.io/getting-started/installation.html)
- [Secrets Store CSI Driver for K8s Secrets](https://github.com/kubernetes-sigs/secrets-store-csi-driver)

- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [Enable Container Insights](https://docs.microsoft.com/azure/azure-monitor/containers/container-insights-onboard)
- [Get a Shell in a running container](https://kubernetes.io/docs/tasks/debug-application-cluster/get-shell-running-container/)
- [Postman Echo API](https://learning.postman.com/docs/developer/echo-api/)

- [GHA Docs](https://docs.github.com/en/actions)
- [GHA Events that trigger Workflows](https://docs.github.com/en/actions/reference/events-that-trigger-workflows)
- [Use AKV Secrets in GHA Workflow](https://docs.microsoft.com/azure/developer/github/github-key-vault)
- [GHA: AKS Set Context](https://github.com/Azure/aks-set-context)
- [GHA Doc: Deploy K8s Manifest](https://github.com/marketplace/actions/deploy-to-kubernetes-cluster)
- [GHA: Deploy K8s Manifest](https://github.com/Azure/k8s-deploy)
- [GHA: YAML Update](https://github.com/fjogeleit/yaml-update-action)

##### Workload

- [.NET DI Service Registration Methods](https://docs.microsoft.com/dotnet/core/extensions/dependency-injection#service-registration-methods)


### 3. Design Decisions

#### Infrastructure

- [Azure Regions with Availability Zones](https://docs.microsoft.com/azure/availability-zones/az-region) are used for regional stamps.
- ARM Templates are used for Infra as Code. Other options include Terraform and Bicep but I decided on ARM due to maturity, broad support, and familiarity.
  - The ARM templates in this repo are as close to single-purpose as possible, for composability into larger deployments. That is, as much as possible each template deploys exactly one type of Azure resource.
- Global resources will be deployed to a single global Resource Group (RG). Each regional stamp will be deployed to its own regional RG.
- API Management multi-region will not be used. Instead, a standalone APIM instance will be deployed to each region. This is due to multi-region APIM's single control plane dependency, which would create a dependency from every other regional stamp to the region where APIM's control plane is deployed.

#### Network

- Each regional stamp will have its own NSGs, VNet, subnets, and other network config.
- There will be no VNet peering between regions as each region is assumed to be independent of the others. Only global resources will know about all regional stamps.
- Initially no private link/endpoints will be used in regional stamps. AKS and some other components are in the regional VNet. PL/PE may be added to optimize network traffic or for security hardening.
- AKS internal networking will use kubenet for simplicity. Internal CIDRs are explicitly specified in deployment. AKS networking may be switched to Azure CNI if needed for performance.
- Azure Front Door will terminate TLS connections. HTTP will be used for intra-stamp communication for simplicity and to avoid TLS overhead.

#### Security

A User-Assigned Managed Identity (UAMI) is provisioned and assigned to resources which support/need a Managed Identity (MI).

A distinct UAMI is deployed to each region. This is to facilitate AKS RBAC. When an AKS instance is configured for managed identity, the managed identity is used to deploy an AKS nodes RG.

An AKS cluster with Application Gateway Ingress Controller (AGIC) creates a new UAMI in the Nodes RG and assigns permissions to that new UAMI as well as the cluster UAMI. This is impractical when the UAMI assigned to the AKS cluster is in the global RG (in fact AGIC deploy will partly fail, yielding 502 bad gateway errors).

Additionally, for least privilege a regional UAMI will not need any permissions over global resources when deployed into the region RG.

The UAMI requires the following RBAC assignments so IaC and app deploys can succeed.

   | **Name** | **Scope** | **Notes**
   | - | - |
   | Contributor | Region RG | Needed for AppGW but at RG level for simplicity.
   | Contributor | Region AKS Node RG | This is assigned automatically during AKS cluster deploy.
   | Network Contributor | Region VNet | Superseded by Region RG Contributor but here to be explicit.
   | Managed Identity Operator | Region RG | Superseded by Region RG Contributor but here to be explicit.
   | Managed Identity Operator | Region AKS Node RG |
   | Virtual Machine Contributor | Region AKS Node RG |

#### CD - Global / Regional Stamp

The global deploy can occur without any regional stamps in place and with no regional dependencies.

Regional deploys can occur without dependency on any other region. There are dependencies on global resources, including for monitoring, database, etc.

##### Global/Single Resources

- App Insights
- Container Insights
- Container Registry (Replications)
- Cosmos DB
- DDoS Plan
- Front Door
- Log Analytics

##### Regional Resources

- Managed Identity
- NSG
- PIP
- VNet and Subnets
- Event Hub
- Key Vault
- App Gateway
- AKS
- APIM

### 4. Workloads

Two Workloads are required: Front End API and Back End Worker. These APIs have the following high-level responsibilities.

#### Front End API (FE)

- Get Player Summary
  - Provided a player GUID, retrieve the player summary from the data store.
  - Summary should include player profile (static data) and up-to-date progress metrics.
- Save Player Progress Data
  - Provided a player progress update, write it to the regional Event Hub.
  - These will be assumed to be append-only / event sourcing model, i.e. insert only.
- Save Player Profile
  - Provided a player profile, write it to the regional Event Hub.
  - These will be assumed to be upserts, so that new players can be created or existing players can be updated.

FE API should include OpenAPI specification for easy import to API Management.

#### Back End Worker (BE)

- Process Player Progress Data
  - Pop progress event off Event Hub.
  - Retrieve player summary from the data store.
  - Calculate updated player metrics from summary and progress event.
  - Persist player progress data to data store. (Event sourcing pattern)
  - Persist updated player summary to data store. (This is the summary combining player static profile data and updated progress metrics.)

- Process Player Profile
  - Pop profile event off Event Hub.
  - Retrieve player summary from data store, or prepare new player summary if player doesn't exist.
  - Write profile data to player summary.
  - Persist player summary to data store.

#### Data Store and Model

Cosmos DB with multi-region write is used as the data store.

Two collections will be used, as follows:

- PlayerSummaries will store the player summaries combining player profile data and progress metrics.
- ProgressEvents will store the player progress data events.

Both collections will be configured as follows:

- No indexing, as reads will be point reads (specify partition key and index) and there will not be projections or other complex queries that would benefit from indexing.
- Autoscale throughput provisioned on each container.
- Partition key will be player ID in both collections.
  - This permits point reads for a player summary, and if analytical or other dependent workloads need it, efficient aggregate queries for events for a specified player.

### 5. Workload Implementation / Tech Notes

#### Config Store

Azure Key Vault is used to store Secrets. These are synced to AKS pods, ultimately accessible as environment variables. Among other benefits, this allows .NET services to retrieve configuration values with the built-in Configuration provider, which by default checks environment variables in addition to other configuration sources.

To update what is retrieved from AKV and synced to pods:

1. Update [/.github/workflows/infra.config.region.yml](/.github/workflows/infra.config.region.yml). Change the action that writes secrets to the regional AKV as needed (e.g. add new secrets). Run this workflow.
2. Update [/src/infra-deploy/secretprovider.ao.akv/yaml](src/infra-deploy/aks/secretprovider.ao.akv.yaml) and add the correct secret names in both _secretobjects_ and _objects_ sections. The _objects_ section makes secrets available in the file system mount (/mnt/secrets-store), and the _secretobjects_ section makes the secrets available as Kubernetes secrets, which in turn are then exposed as environment variables. Deploy this updated manifest to your cluster.
3. Update the workload manifests [back end](/src/workload-deploy/aks/workload.back.yaml) and [front end](/src/workload-deploy/aks/workload.front.yaml) with the secret changes. Deploy these updated manifests to your cluster.
4. You should now be able to shell to a workload pod, ls or cat the filesystem mounted secret store values, and echo the environment variables successfully.

### 6. Tech Stack Notes

#### AKS

Install kubectl locally: [az aks install-cli](https://docs.microsoft.com/cli/azure/aks#az_aks_install_cli)
Connect to cluster: [az aks get-credentials](https://docs.microsoft.com/cli/azure/aks#az_aks_get_credentials) 

[Cluster auto-scaler](https://docs.microsoft.com/azure/aks/cluster-autoscaler)
[Cluster authorized IP ranges](https://docs.microsoft.com/azure/aks/api-server-authorized-ip-ranges)
[AAD pod-managed identities (preview)](https://docs.microsoft.com/azure/aks/use-azure-ad-pod-identity)
[BYO kubelet MI (preview)](https://docs.microsoft.com/azure/aks/use-managed-identity#bring-your-own-kubelet-mi-preview)

Enabling preview features (kubelet MI, pod identity) requires separate steps. See [aks-init.sh](./scripts/aks-init.sh) for details of registering previews and updating the AKS RP.

Test [Multi-Container App](https://docs.microsoft.com/azure/aks/kubernetes-walkthrough-rm-template). A version of the deployment is provided in this repo, modified from the original for AGIC instead of Load Balancer (LB) ingress.

``` bash
kubectl apply -f ./aks/azure-vote.yaml
```

Enable Cluster Monitoring (Container Insights):
[New cluster](https://docs.microsoft.com/azure/aks/kubernetes-walkthrough#enable-cluster-monitoring)
[Existing cluster](https://docs.microsoft.com/azure/azure-monitor/containers/container-insights-enable-existing-clusters#integrate-with-an-existing-workspace)

Use AKV with Secrets Store CSI Driver
[Dev Best Practices - Use AKV](https://docs.microsoft.com/azure/aks/developer-best-practices-pod-security#use-azure-key-vault-with-secrets-store-csi-driver)
[Install Secrets Store CSI Driver](https://secrets-store-csi-driver.sigs.k8s.io/getting-started/installation.html)
[AKV Provider for Secret Store CSI Driver](https://github.com/Azure/secrets-store-csi-driver-provider-azure)
[AKV Provider for Secret Store CSI Driver Docs - Install, Use, Demos, etc.](https://azure.github.io/secrets-store-csi-driver-provider-azure/getting-started/installation/)



### 6. Parking Lot

- Multiple stamps _per region_
- Custom domain instead of azurefd
- Custom domain SSL cert
- Private link and endpoint in each region
- Central config store for github workflows instead of reproducing environment var setup in each workflow file
