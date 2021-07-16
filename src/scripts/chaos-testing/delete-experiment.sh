#!/bin/bash

# NOTE THIS DOES NOT WORK YET - DELETE EXPERIMENT ON CHAOS PG ROADMAP FOR MID-2021

subscriptionId=$1
resourceGroupName=$2
experimentName=$3

if [ -z "$subscriptionId" ] || [ -z "$resourceGroupName" ] || [ -z "$experimentName" ]
then
	echo "Usage: ./delete-experiment.sh YOUR_AZURE_SUBSCRIPTION_ID YOUR_EXPERIMENT_RESOURCE_GROUP YOUR_EXPERIMENT_NAME"
	exit 0
fi

apiVersion="2021-06-07-preview"

url="https://management.azure.com/subscriptions/""$subscriptionId""/resourceGroups/""$resourceGroupName""/providers/Microsoft.Chaos/chaosExperiments/""$experimentName""?api-version=""$apiVersion"

az rest --method delete --url "$url" --verbose
