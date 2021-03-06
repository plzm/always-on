#!/bin/bash

subscriptionId=$1
chaosProviderType=$2

if [ -z "$subscriptionId" ] || [ -z "$chaosProviderType" ]
then
	echo "Usage: ./delete-provider-config.sh YOUR_AZURE_SUBSCRIPTION_ID YOUR_CHAOS_PROVIDER_TYPE"
	exit 0
fi

apiVersion="2021-06-07-preview"

url="https://management.azure.com/subscriptions/""$subscriptionId""/providers/Microsoft.Chaos/chaosProviderConfigurations/""$chaosProviderType""?api-version=""$apiVersion"

az rest --method delete --url "$url"