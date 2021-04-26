# ALWAYS ON

(Ref. canonical Always On source doc)

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
