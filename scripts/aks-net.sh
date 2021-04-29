#!/bin/bash

subscriptionId="$(az account show -o tsv --query 'id')"
location="eastus"
resourceGroup="always-on-9"
clusterName="ao-aks-eus"
appGwName="ao-appgw-eus"
publicIpNameAppGw="ao-appgw-pip-eus"

extIpRange="75.68.47.183/32"

# Get existing authorized IP ranges
 az aks show --subscription "$subscriptionId" -g "$resourceGroup" -n "$clusterName" --query 'apiServerAccessProfile.authorizedIpRanges' --verbose

# Disable authorized IP ranges
# az aks update --subscription "$subscriptionId" -g "$resourceGroup" -n "$clusterName" --api-server-authorized-ip-ranges ""

#publicIpIds=("$(az network application-gateway frontend-ip list --subscription "$subscriptionId" -g "$resourceGroup" --gateway-name "$appGwName" -o tsv --query "[].publicIpAddress.id")")

#appGwPublicIp="$(az network public-ip show --ids "${publicIpIds[0]}" -o tsv --query "ipAddress")"

#authorizedIps="$extIpRange"",""$appGwPublicIp""/32"

# echo $authorizedIps

#az aks update --subscription "$subscriptionId" -g "$resourceGroup" -n "$clusterName" --api-server-authorized-ip-ranges "$authorizedIps" --verbose
