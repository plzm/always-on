#!/bin/bash

subscriptionId="$(az account show -o tsv --query 'id')"
resourceGroup="test-chaos"
location="eastus2euap"

templatePath="../templates/experiment.aks.json"

experimentName="chaos-aks-02"
faultType="NetworkChaos"

chaosMeshSpecPath="../chaos-mesh/network-chaos.network-bandwidth.json"
chaosMeshSpec=$(cat $chaosMeshSpecPath)

aksId1="/subscriptions/e61e4c75-268b-4c94-ad48-237aa3231481/resourcegroups/always-on-eastus2/providers/Microsoft.ContainerService/managedClusters/pz-ao-eastus2"
# aksId2="/subscriptions/e61e4c75-268b-4c94-ad48-237aa3231481/resourcegroups/always-on-westus2/providers/Microsoft.ContainerService/managedClusters/pz-ao-westus2"

az deployment group create --subscription "$subscriptionId" -n "Experiment-AKS" --verbose \
	-g "$resourceGroup" --template-file "$templatePath" \
	--parameters \
	location="$location" experimentName="$experimentName" \
  targetResourceIds="$aksId1" \
	chaosMeshFaultType="$faultType" chaosMeshSpec="$chaosMeshSpec"
