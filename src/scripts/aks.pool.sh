#!/bin/bash

PREFIX="pz-ao"
SUFFIX="27"

subscriptionId="$(az account show -o tsv --query 'id')"
location="eastus2"
resourceGroup="always-on-""$location"
clusterName="pz-ao-""$location"

appSubnetId="/subscriptions/""$subscriptionId""/resourceGroups/always-on-eastus2/providers/Microsoft.Network/virtualNetworks/pz-ao-eastus2/subnets/app"

az deployment group create --subscription "$subscriptionId" -n "cdb" --verbose \
	-g "$resourceGroup" --template-file "../infra-deploy/templates/aks.node-pool.json" \
	--parameters \
		location=$location clusterName=$clusterName availabilityZones="1,2,3" nodePoolMode=User nodePoolName="aopool" \
		nodeCount=1 enableNodeAutoscale=true nodeCountMin=1 nodeCountMax=2 nodeVmSize="Standard_DS2_v2" osDiskSizeGB=60 \
		subnetResourceId="$appSubnetId" \
		nodeLabels='{"app": "ao", "foo": "bar"}'

