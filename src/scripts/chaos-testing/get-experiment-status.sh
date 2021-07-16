#!/bin/bash

subscriptionId=$1
resourceGroupName=$2
experimentName=$3

if [ -z "$subscriptionId" ] || [ -z "$resourceGroupName" ] || [ -z "$experimentName" ]
then
	echo "Usage: ./get-experiment.sh YOUR_AZURE_SUBSCRIPTION_ID YOUR_EXPERIMENT_RESOURCE_GROUP YOUR_EXPERIMENT_NAME"
	exit 0
fi

apiVersion="2021-06-07-preview"

# Get Experiment ID
url="https://management.azure.com/subscriptions/""$subscriptionId""/resourceGroups/""$resourceGroupName""/providers/Microsoft.Chaos/chaosExperiments/""$experimentName""?api-version=""$apiVersion"
experimentId="$(az rest --method get --url "$url" -o tsv --query 'id')"

#echo "Get Execution Detail"
#url="https://management.azure.com/""$experimentId""/executiondetails/{executionDetailsId}?api-version=""$apiVersion"
#az rest --method get --url $url

echo "Get last two Execution Details"
url="https://management.azure.com/""$experimentId""/executiondetails?api-version=""$apiVersion"
az rest --method get --url $url

# Broken
#echo "Get Status"
#url="https://management.azure.com/""$experimentId""/status?api-version=""$apiVersion"
#az rest --method get --url "$url"

echo "Get Statuses (History)"
url="https://management.azure.com/""$experimentId""/statuses?api-version=""$apiVersion"
az rest --method get --url "$url"
