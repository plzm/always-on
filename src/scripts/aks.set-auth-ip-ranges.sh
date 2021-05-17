#!/bin/bash

# https://docs.microsoft.com/azure/aks/api-server-authorized-ip-ranges

subscriptionId="$(az account show -o tsv --query 'id')"
location="northeurope"
resourceGroup="always-on-""$location"
clusterName="pz-ao-""$location"
appGwName="pz-ao-""$location"
publicIpNameAppGw="pz-ao-appgw-""$location"

extIpRange="75.68.47.183/32"

# Get existing authorized IP ranges
 az aks show --subscription "$subscriptionId" -g "$resourceGroup" -n "$clusterName" --query 'apiServerAccessProfile.authorizedIpRanges' --verbose

# Disable authorized IP ranges
# az aks update --subscription "$subscriptionId" -g "$resourceGroup" -n "$clusterName" --api-server-authorized-ip-ranges ""

publicIpIds=("$(az network application-gateway frontend-ip list --subscription "$subscriptionId" -g "$resourceGroup" --gateway-name "$appGwName" -o tsv --query "[].publicIpAddress.id")")
echo $publicIpIds

appGwPublicIp="$(az network public-ip show --ids "${publicIpIds[0]}" -o tsv --query "ipAddress")"
echo $appGwPublicIp

authorizedIps="$extIpRange"",""$appGwPublicIp""/32"
echo $authorizedIps

az aks update --subscription "$subscriptionId" -g "$resourceGroup" -n "$clusterName" --api-server-authorized-ip-ranges "$authorizedIps" --verbose
