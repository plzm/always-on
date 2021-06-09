#!/bin/bash

az extension add --name application-insights
az extension add --name front-door

prefix="pz-ao"
suffix="31"

subscriptionId="$(az account show -o tsv --query 'id')"

appInsightsName="$prefix"

locationGlobal="eastus2"
resourceGroupGlobal="always-on-global"


# Front Door
frontDoorName="$prefix"
frontDoorEndpointName="$frontDoorName"
frontDoorEndpointFqdn="$(az afd endpoint show --subscription $subscriptionId -g $resourceGroupGlobal --profile-name $frontDoorName --endpoint-name $frontDoorEndpointName -o tsv --query 'hostName')"

webTestName="afd-""$frontDoorName"
testUrl="https://""$frontDoorEndpointFqdn"

az deployment group create --subscription "$subscriptionId" -n "$webTestName" --verbose \
	-g "$resourceGroupGlobal" --template-file "../infra-deploy/templates/monitor.app-insights.web-test.json" \
	--parameters location="$locationGlobal" appInsightsName="$appInsightsName" webTestName="$webTestName" testUrl="$testUrl"

# APIM eastus2
location="eastus2"
resourceGroup="always-on-""$location"
apimName="$prefix""-""$location""-""$suffix"
apimEndpointFqdn="$(az apim show --subscription $subscriptionId -g "$resourceGroup" -n $apimName -o tsv --query 'hostnameConfigurations[0].hostName')"

webTestName="apim-""$apimName"
testUrl="http://""$apimEndpointFqdn"

az deployment group create --subscription "$subscriptionId" -n "$webTestName" --verbose \
	-g "$resourceGroupGlobal" --template-file "../infra-deploy/templates/monitor.app-insights.web-test.json" \
	--parameters location="$locationGlobal" appInsightsName="$appInsightsName" webTestName="$webTestName" testUrl="$testUrl"

# APIM westus2
location="westus2"
resourceGroup="always-on-""$location"
apimName="$prefix""-""$location""-""$suffix"
apimEndpointFqdn="$(az apim show --subscription $subscriptionId -g "$resourceGroup" -n $apimName -o tsv --query 'hostnameConfigurations[0].hostName')"

webTestName="apim-""$apimName"
testUrl="http://""$apimEndpointFqdn"

az deployment group create --subscription "$subscriptionId" -n "$webTestName" --verbose \
	-g "$resourceGroupGlobal" --template-file "../infra-deploy/templates/monitor.app-insights.web-test.json" \
	--parameters location="$locationGlobal" appInsightsName="$appInsightsName" webTestName="$webTestName" testUrl="$testUrl"

# AppGW eastus2
location="eastus2"
resourceGroup="always-on-""$location"
appGwName="$prefix""-""$location"
appGwPublicIpName="$prefix""-appgw-""$location"
appGwEndpointFqdn="$(az network public-ip show --subscription "$subscriptionId" -g "$resourceGroup" -n $appGwPublicIpName -o tsv --query 'dnsSettings.fqdn')"

webTestName="appgw-""$appGwName"
testUrl="http://""$appGwEndpointFqdn"

az deployment group create --subscription "$subscriptionId" -n "$webTestName" --verbose \
	-g "$resourceGroupGlobal" --template-file "../infra-deploy/templates/monitor.app-insights.web-test.json" \
	--parameters location="$locationGlobal" appInsightsName="$appInsightsName" webTestName="$webTestName" testUrl="$testUrl"

# AppGW westus2
location="westus2"
resourceGroup="always-on-""$location"
appGwName="$prefix""-""$location"
appGwPublicIpName="$prefix""-appgw-""$location"
appGwEndpointFqdn="$(az network public-ip show --subscription "$subscriptionId" -g "$resourceGroup" -n $appGwPublicIpName -o tsv --query 'dnsSettings.fqdn')"

webTestName="appgw-""$appGwName"
testUrl="http://""$appGwEndpointFqdn"

az deployment group create --subscription "$subscriptionId" -n "$webTestName" --verbose \
	-g "$resourceGroupGlobal" --template-file "../infra-deploy/templates/monitor.app-insights.web-test.json" \
	--parameters location="$locationGlobal" appInsightsName="$appInsightsName" webTestName="$webTestName" testUrl="$testUrl"
