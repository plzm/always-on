#!/bin/bash

subscriptionId=$1
resourceGroupName=$2
experimentName=$3

if [ -z "$subscriptionId" ] || [ -z "$resourceGroupName" ] || [ -z "$experimentName" ]
then
	echo "Usage: ./run-experiment.sh YOUR_AZURE_SUBSCRIPTION_ID YOUR_EXPERIMENT_RESOURCE_GROUP YOUR_EXPERIMENT_NAME"
	exit 0
fi

apiVersion="2021-06-07-preview"

# Get Experiment Resource ID
url="https://management.azure.com/subscriptions/""$subscriptionId""/resourceGroups/""$resourceGroupName""/providers/Microsoft.Chaos/chaosExperiments/""$experimentName""?api-version=""$apiVersion"
experimentId="$(az rest --method get --url $url -o tsv --query 'id')"

# Run Experiment
url="https://management.azure.com/""$experimentId""/start?api-version=""$apiVersion"
az rest --method post --url $url
