#!/bin/bash

subscriptionId=$1
resourceGroupName=$2

if [ -z "$subscriptionId" ] || [ -z "$resourceGroupName" ]
then
	echo "Usage: ./list-experiment.sh YOUR_AZURE_SUBSCRIPTION_ID YOUR_EXPERIMENT_RESOURCE_GROUP"
	exit 0
fi

apiVersion="2021-06-07-preview"

url="https://management.azure.com/subscriptions/""$subscriptionId""/resourceGroups/""$resourceGroupName""/providers/Microsoft.Chaos/chaosExperiments?api-version=""$apiVersion"

az rest --method get --url "$url"
