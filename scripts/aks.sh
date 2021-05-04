#!/bin/bash

# General
myIp="75.68.47.183/32"
location="eastus"
subscriptionId="$(az account show -o tsv --query 'id')"

# Deployment
infix="12"
resourceGroup="always-on-""$infix"

# RBAC
rbacRoleIdReader="acdd72a7-3385-48ef-bd42-f606fba81ae7"

# UAMI
managedIdentityName="pz-ao-uami-""$infix"
managedIdentityType="UserAssigned"
identityResourceId="$(az identity show --subscription ""$subscriptionId"" -g ""$resourceGroup"" -n ""$managedIdentityName"" -o tsv --query 'id')"
identityPrincipalId="$(az identity show --subscription ""$subscriptionId"" -g ""$resourceGroup"" -n ""$managedIdentityName"" -o tsv --query 'principalId')"

# Log Analytics
laWorkspaceName="ao-la-eus"
laWorkspaceResourceId="$(az monitor log-analytics workspace show --subscription ""$subscriptionId"" -g ""$resourceGroup"" -n "$laWorkspaceName" -o tsv --query 'id')"

# Network
vnetName="ao-eus"
subnetNameApp="App"
subnetNameAppGw="AppGw"
subnetNameApim="Apim"
subnetAppResourceId="$(az network vnet subnet show --subscription ""$subscriptionId"" -g ""$resourceGroup"" --vnet-name ""$vnetName"" -n ""$subnetNameApp"" -o tsv --query 'id')"

# App GW
appGwName="ao-appgw-eus"
appGwResourceId="$(az network application-gateway show --subscription ""$subscriptionId"" -g ""$resourceGroup"" -n "$appGwName" -o tsv --query 'id')"
appGwPublicIpName="ao-appgw-pip-eus"
appGwPublicIpAddress="$(az network public-ip show --subscription "$subscriptionId" -g "$resourceGroup" -n "$appGwPublicIpName" -o tsv --query 'ipAddress')"

# AKS
clusterName="ao-aks-test"
nodeResourceGroup="$resourceGroup""-""$clusterName""-""$location"
k8sversion="1.20.5"
dnsPrefix="aoakstest"
nodeCount=1
nodeVmSize="Standard_DS2_v2"
nodeAdminUsername="pelazem"
sshRSAPublicKey="ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAg+4FzJlW5nqUa798vqYGanooy5HvSyG8sS6KjPu0sJAf+fkP6qpHY8k1m2/Z9Mahv2Y0moZDiVRHFMGH8qZU+AlYdvjGyjxHcIzDnsmHcV2ONxEiop4KMJLwecHUyf95ogicB1QYfK/6Q8pL9sDlXt8bAcSh6iP0u2d1g9QJaON2aniOpzn68xnKdGT974i7JQLN0SjaPiidZ2prc0cSIMBN26tGV7at2Jh5FIb1Jv8fXHnZebD/vgLilfCqLbuQjTpDVCskZ+OUAyvlBko3gBjRgd/jBprMqCpFLoGUBVkSSR0IkjTj2A6n2XyCyYRMFYrVrjwyU8I+IvO/6zJSEw== pelazem"
apiServerAuthorizedIpRanges="$appGwPublicIpAddress""/32,""$myIp"
networkPlugin="kubenet"
serviceCidr="10.1.0.0/16"
dnsServiceIp="10.1.0.10"
podCidr="10.241.0.0/16"
dockerBridgeAddress="172.17.0.1/16"
zones="1 2 3"

# Create AKS cluster with control plane and kubelet MI
az aks create --subscription "$subscriptionId" -g "$resourceGroup" -l "$location" --verbose \
	-n "$clusterName" --zones $zones --kubernetes-version "$k8sversion" --dns-name-prefix "$dnsPrefix" \
	--enable-managed-identity --assign-identity "$identityResourceId" --assign-kubelet-identity "$identityResourceId" \
	--node-resource-group "$nodeResourceGroup" --node-count "$nodeCount" --node-vm-size "$nodeVmSize" \
	--admin-username "$nodeAdminUsername" --ssh-key-value "$sshRSAPublicKey" \
	--vnet-subnet-id "$subnetAppResourceId" --api-server-authorized-ip-ranges "$apiServerAuthorizedIpRanges" \
	--network-plugin "$networkPlugin" --service-cidr "$serviceCidr" --dns-service-ip "$dnsServiceIp" --pod-cidr "$podCidr" --docker-bridge-address "$dockerBridgeAddress"

## Grant UAMI Reader on AKS Nodes RG for Pod Managed Identity - RG is created by AKS deploy and cannot exist before
#az role assignment create --subscription "$subscriptionId" -g "$resourceGroup" --role "$rbacRoleIdReader" --assignee-object-id "$identityPrincipalId"

## Configure AKS Add-ons - Monitoring, AGIC
#az aks enable-addons --subscription "$subscriptionId" -g "$resourceGroup" -n "$clusterName" -a monitoring,ingress-appgw --workspace-resource-id "$laWorkspaceResourceId" --appgw-id "$appGwResourceId"

## Enabled Pod Managed identity
#az aks update --subscription "$subscriptionId" -g "$resourceGroup" -n "$clusterName" --enable-pod-identity --enable-pod-identity-with-kubenet

## Add Pod Identity
#az aks pod-identity add --subscription "$subscriptionId" -g "$resourceGroup" --cluster-name "$clusterName" --namespace "default" --name "$managedIdentityName" --identity-resource-id "$identityResourceId"



#az deployment group create --subscription "$subscriptionId" -n "AKS" --verbose \
#	-g "$resourceGroup" --template-file "../templates/aks.cluster.json" \
#	--parameters \
#	location="$location" clusterName="$clusterName" dnsPrefix="$dnsPrefix" \
#	managedIdentityType="$managedIdentityType" identityResourceId="$identityResourceId" \
#	nodeAdminUsername="$nodeAdminUsername" sshRSAPublicKey="$sshRSAPublicKey" \
#	vnetSubnetResourceId="$subnetAppResourceId"

# App GW Public IP
#az deployment group create --subscription "$subscriptionId" -n "PIP" --verbose \
#	-g "$resourceGroup" --template-file "../templates/net.public-ip.json" \
#	--parameters \
#	location="$location" publicIpName="$appGwPublicIpName" availabilityZones="1,2,3" \
#	publicIpType="Static" publicIpSku="Standard" domainNameLabel="$appGwPublicIpName"

# App GW
#az deployment group create --subscription "$subscriptionId" -n "AppGW" --verbose \
#	-g "$resourceGroup" --template-file "../templates/net.app-gw.json" \
#	--parameters \
#	location="$location" appGatewayName="$appGwName" skuName="WAF_v2" availabilityZones="1,2,3" \
#	vnetResourceGroup="$resourceGroup" vnetName="$vnetName" subnetName="$subnetNameAppGw" \
#	publicIpResourceGroup="$resourceGroup" publicIpName="$appGwPublicIpName"

# Get/overwrite AKS credentials
#az aks get-credentials --subscription "$subscriptionId" -g "$resourceGroup" -n "$clusterName" --overwrite-existing --verbose

# Show AKS cluster identity config
#az aks show -g "$resourceGroup" -n "$clusterName" --query "servicePrincipalProfile"
#az aks show -g "$resourceGroup" -n "$clusterName" --query "identity"

# As this includes an ingress, will take a few minutes for App GW to finish updating
#kubectl apply -f ../aks/azure-vote.yaml
