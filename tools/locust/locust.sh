#!/bin/bash

PREFIX="pz-ao"
SUFFIX="31"

subscriptionId="$(az account show -o tsv --query 'id')"
resourceGroup="always-on-tests"
location="eastus2"
apiUri="https://pz-ao.z01.azurefd.net/api"
numberOfInstances=1
numberOfUsers=10
numberOfUsersToSpawnPerSecond=1
runtime=5m
stopTimeoutSeconds=10
storageAccountName=pzaotests
fileShareName=locust

az deployment group create --subscription "$subscriptionId" -n "locust" --verbose \
	-g "$resourceGroup" --template-file "../../src/infra-deploy/templates/locust.json" \
	--parameters \
		location=$location hostToTest=$apiUri numberOfInstances=$numberOfInstances \
		numberOfUsers=$numberOfUsers numberOfUsersToSpawnPerSecond=$numberOfUsersToSpawnPerSecond runtime=$runtime stopTimeoutSeconds=$stopTimeoutSeconds \
		storageAccountResourceGroup=$resourceGroup storageAccountName=$storageAccountName fileShareName=$fileShareName
