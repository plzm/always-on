#!/bin/bash

subscriptionId="$(az account show -o tsv --query 'id')"
location="eastus"
resourceGroup="always-on-9"
templateFile="../templates/aks.cluster.json"

clusterName="ao-aks-eus"
dnsPrefix="aoakseus"

managedIdentityType="UserAssigned"
identityResourceId="/subscriptions/e61e4c75-268b-4c94-ad48-237aa3231481/resourceGroups/always-on-9/providers/Microsoft.ManagedIdentity/userAssignedIdentities/pz-ao-uami-9"

nodeAdminUsername="pelazem"
sshRSAPublicKey="ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAg+4FzJlW5nqUa798vqYGanooy5HvSyG8sS6KjPu0sJAf+fkP6qpHY8k1m2/Z9Mahv2Y0moZDiVRHFMGH8qZU+AlYdvjGyjxHcIzDnsmHcV2ONxEiop4KMJLwecHUyf95ogicB1QYfK/6Q8pL9sDlXt8bAcSh6iP0u2d1g9QJaON2aniOpzn68xnKdGT974i7JQLN0SjaPiidZ2prc0cSIMBN26tGV7at2Jh5FIb1Jv8fXHnZebD/vgLilfCqLbuQjTpDVCskZ+OUAyvlBko3gBjRgd/jBprMqCpFLoGUBVkSSR0IkjTj2A6n2XyCyYRMFYrVrjwyU8I+IvO/6zJSEw== pelazem"

vnetName="ao-eus"
subnetNameApp="App"
subnetNameAppGw="AppGw"
subnetNameApim="Apim"
subnetAppResourceId="$(az network vnet subnet show --subscription ""$subscriptionId"" -g ""$resourceGroup"" --vnet-name ""$vnetName"" -n ""$subnetNameApp"" -o tsv --query 'id')"

appGwName="ao-appgw-eus"
publicIpNameAppGw="ao-appgw-pip-eus"

#az deployment group create --subscription "$subscriptionId" -n "AKS" --verbose \
#	-g "$resourceGroup" --template-file "$templateFile" \
#	--parameters \
#	location="$location" clusterName="$clusterName" dnsPrefix="$dnsPrefix" \
#	managedIdentityType="$managedIdentityType" identityResourceId="$identityResourceId" \
#	nodeAdminUsername="$nodeAdminUsername" sshRSAPublicKey="$sshRSAPublicKey" \
#	vnetSubnetResourceId="$subnetAppResourceId"

# App GW Public IP
#az deployment group create --subscription "$subscriptionId" -n "PIP" --verbose \
#	-g "$resourceGroup" --template-file "../templates/net.public-ip.json" \
#	--parameters \
#	location="$location" publicIpName="$publicIpNameAppGw" availabilityZones="1,2,3" \
#	publicIpType="Static" publicIpSku="Standard" domainNameLabel="$publicIpNameAppGw"

# App GW
#az deployment group create --subscription "$subscriptionId" -n "AppGW" --verbose \
#	-g "$resourceGroup" --template-file "../templates/net.app-gw.json" \
#	--parameters \
#	location="$location" appGatewayName="$appGwName" skuName="WAF_v2" availabilityZones="1,2,3" \
#	vnetResourceGroup="$resourceGroup" vnetName="$vnetName" subnetName="$subnetNameAppGw" \
#	publicIpResourceGroup="$resourceGroup" publicIpName="$publicIpNameAppGw"

# Get/overwrite AKS credentials
az aks get-credentials --subscription "$subscriptionId" -g "$resourceGroup" -n "$clusterName" --overwrite-existing --verbose

# Show AKS cluster identity config
#az aks show -g "$resourceGroup" -n "$clusterName" --query "servicePrincipalProfile"
#az aks show -g "$resourceGroup" -n "$clusterName" --query "identity"


kubectl apply -f ../aks/azure-vote.yaml
