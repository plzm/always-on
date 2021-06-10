#!/bin/bash

PREFIX="pz-ao"
SUFFIX="31"

subscriptionId="$(az account show -o tsv --query 'id')"
location="eastus2"
resourceGroup="always-on-""$location"
serviceName="$PREFIX""-""$location""-""$SUFFIX"

skuName="Premium"
scaleUnits=9
availabilityZones="1,2,3"

uamiName="$PREFIX""-""$location"
uamiId="$(az identity show --subscription $subscriptionId -g $resourceGroup -n $uamiName -o tsv --query 'id')"

publicIpName="$PREFIX""-apim-p-""$location"

vnetName="$PREFIX""-""$location"
subnetName="apim"
subnetResourceId="$(az network vnet subnet show --subscription $subscriptionId -g $resourceGroup --vnet-name $vnetName -n $subnetName -o tsv --query 'id')"

# New public IP to scale to Premium
az deployment group create --subscription "$subscriptionId" -n "$publicIpName" --verbose \
	-g "$resourceGroup" --template-file "../infra-deploy/templates/net.public-ip.json" \
	--parameters \
	location="$location" publicIpName="$publicIpName" availabilityZones="$availabilityZones" \
	publicIpType="Static" publicIpSku="Standard" domainNameLabel="$publicIpName"

# Scale APIM to Premium
az deployment group create --subscription "$subscriptionId" -n "$serviceName" --verbose \
	-g "$resourceGroup" --template-file "../infra-deploy/templates/apim.service.json" \
	--parameters \
	location="$location" apimServiceName="$serviceName" skuName="$skuName" availabilityZones="$availabilityZones" \
	scaleUnits=$scaleUnits managedIdentityType="UserAssigned" identityResourceId="$uamiId" \
	publicIpResourceGroup="$resourceGroup" publicIpName="$publicIpName" \
	virtualNetworkType="External" subnetResourceId="$subnetResourceId"
