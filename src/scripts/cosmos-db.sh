#!/bin/bash

prefix="pz-ao"
suffix="31"

subscriptionId="$(az account show -o tsv --query 'id')"
location="eastus2"

resourceGroup="always-on-global"


az deployment group create --subscription "$subscriptionId" -n "cdb" --verbose \
	-g "$resourceGroup" --template-file "../infra-deploy/templates/cosmos-db.sql.container.json" \
	--parameters \
	location="$location" cosmosDbAccountName="$prefix" databaseName="ao" \
	containerName="test2" partitionKeyPath="/Handle" \
	provisionedThroughput="400" autoscaleMaxThroughput="0"