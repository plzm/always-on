#!/bin/bash

while getopts ":location:" arg
do
	location=$OPTARG
done

if [[ -z "$location" ]]
then
	echo "Usage: ./apim.scale.sh -location eastus2. Please provide an Azure location like eastus2, westus2, etc."
	exit 0
fi

PREFIX="pz-ao"
SUFFIX="34"

subscriptionId="$(az account show -o tsv --query 'id')"
resourceGroup="always-on-""$location"
serviceName="$PREFIX""-""$location""-""$SUFFIX"

#skuName="Premium"
skuName="Developer"

# scaleUnits and availabilityZones for Premium, but will be overridden inside template if Developer set. So, no need to change these to change scale.
scaleUnits=3
availabilityZones="1,2,3"

uamiName="$PREFIX""-""$location"
uamiId="$(az identity show --subscription $subscriptionId -g $resourceGroup -n $uamiName -o tsv --query 'id')"

# APIM public IP name infix with d or p (Developer or Premium) for clarity in scaling operations, where we need separate PIP to change APIM SKU
if [[ $skuName == "Developer" ]]
then
	apimPublicIpInfix='-apim-d-'
elif [[ $skuName == "Premium" ]]
then
	apimPublicIpInfix='-apim-p-'
else
	apimPublicIpInfix='-apim-z-'
fi

publicIpName="$PREFIX""$apimPublicIpInfix""$location"
echo $publicIpName

vnetName="$PREFIX""-""$location"
subnetName="apim"
subnetResourceId="$(az network vnet subnet show --subscription $subscriptionId -g $resourceGroup --vnet-name $vnetName -n $subnetName -o tsv --query 'id')"

# Public IP
az deployment group create --subscription "$subscriptionId" -n "$publicIpName" --verbose \
	-g "$resourceGroup" --template-file "../infra-deploy/templates/net.public-ip.json" \
	--parameters \
	location="$location" publicIpName="$publicIpName" availabilityZones="$availabilityZones" \
	publicIpType="Static" publicIpSku="Standard" domainNameLabel="$publicIpName"

# Scale APIM
az deployment group create --subscription "$subscriptionId" -n "$serviceName" --verbose \
	-g "$resourceGroup" --template-file "../infra-deploy/templates/apim.service.json" \
	--parameters \
	location="$location" apimServiceName="$serviceName" skuName="$skuName" availabilityZones="$availabilityZones" \
	scaleUnits=$scaleUnits managedIdentityType="UserAssigned" identityResourceId="$uamiId" \
	publicIpResourceGroup="$resourceGroup" publicIpName="$publicIpName" \
	virtualNetworkType="External" subnetResourceId="$subnetResourceId"
