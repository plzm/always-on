#!/bin/bash

subscriptionId=$1
chaosProviderType=$2

if [ -z "$subscriptionId" ] || [ -z "$chaosProviderType" ]
then
	echo "Usage: ./list-provider-target.sh YOUR_AZURE_SUBSCRIPTION_ID YOUR_CHAOS_PROVIDER_TYPE"
	exit 0
fi

apiVersion="2021-06-07-preview"

url="https://management.azure.com/subscriptions/""$subscriptionId""/providers/Microsoft.Chaos/chaosTargets?api-version=""$apiVersion""&chaosProviderType=""$chaosProviderType"

az rest --method get --url "$url"
