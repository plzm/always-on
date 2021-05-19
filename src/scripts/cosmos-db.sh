#!/bin/bash

prefix="pz-ao"
suffix="23"

subscriptionId="$(az account show -o tsv --query 'id')"
location="eastus"

resourceGroup="always-on-global"


az deployment group create --subscription "$subscriptionId" -n "cdb" --verbose --debug \
	-g "$resourceGroup" --template-file "../infra-deploy/templates/cosmos-db.sql.container.json" \
	--parameters \
	location="$location" cosmosDbAccountName="$prefix" databaseName="ao" \
	containerName="test" partitionKeyPath="/id" \
	provisionedThroughput="400" autoscaleMaxThroughput="0"