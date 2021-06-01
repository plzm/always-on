# ALWAYS ON

![Infra-DeployGlobal](https://github.com/plzm/always-on/actions/workflows/infra.deploy.global.yml/badge.svg)
![Infra-DeployRegion](https://github.com/plzm/always-on/actions/workflows/infra.deploy.region.yml/badge.svg)
![Infra-ConfigRegion](https://github.com/plzm/always-on/actions/workflows/infra.config.region.yml/badge.svg)
![App-Build](https://github.com/plzm/always-on/actions/workflows/app.build.yml/badge.svg)
![App-Deploy](https://github.com/plzm/always-on/actions/workflows/app.deploy.yml/badge.svg)

## SUMMARY

This solution deploys and configures a highly performant, multi-region application on Azure. All deployments and configurations are performed by github Actions workflows for maximal automation and CI/CD.

## CONTENTS

1. [Scenario and Non-Functional Requirements](./media/docs/01.scenario-nfrs.md)
2. [Architectures](./media/docs/02.architectures.md)
3. [Design and Technology Decisions](./media/docs/03.design-tech-decisions.md)
4. [Tooling and References](./media/docs/04.tooling-refs.md)
5. [Workloads](./media/docs/05.workloads.md)
6. [Approach and Tasks](media/docs/06.approach.md)



### APPROACH


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

#### Useful References


##### Workload

- [.NET DI Service Registration Methods](https://docs.microsoft.com/dotnet/core/extensions/dependency-injection#service-registration-methods)


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

1. Update [/src/infra-deploy/secretprovider.ao.akv.yaml](src/infra-deploy/aks/secretprovider.ao.akv.yaml) and add the correct secret names in both _secretobjects_ and _objects_ sections. The _objects_ section makes secrets available in the file system mount (/mnt/secrets-store), and the _secretobjects_ section makes the secrets available as Kubernetes secrets, which in turn are then exposed as environment variables. Deploy this updated manifest to your cluster.
   1. NOTE!! The infra.config.region.yml workflow writes two required values into this YAML file. If you are running from the command line with kubectl, you MUST manually add two values, `tenantId` and `keyVaultName` to the file before applying the manifest.
2. Update [/.github/workflows/infra.config.region.yml](/.github/workflows/infra.config.region.yml). Change the action that writes secrets to the regional AKV as needed (e.g. add new secrets).
3. Update the workload manifests [back end](/src/workload-deploy/aks/ao.be.yaml) and [front end](/src/workload-deploy/aks/ao.fe.yaml) with the secret changes. Deploy these updated manifests to your cluster.
   1. NOTE!! The app.deploy.yml workflow writes a required value into this YAML file. If you are running from the command line with kubectl, you MUST manually add the value for `aadpodidbinding` to the file before applying the manifest. At this time, the binding defaults to $UAMI_NAME-binding (e.g. pz-ao-eastus-binding). This appears to be internally set, with the binding ID specified when adding pod identity to the AKS cluster being a reference to this, NOT the actual name to be used for the binding.
4. Run infra.config.region, then app.deploy.
5. You should now be able to shell to a workload pod, ls or cat the filesystem mounted secret store values, and echo the environment variables successfully.

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
