#!/bin/bash

subscriptionId=$1

if [ -z "$subscriptionId" ]
then
	echo "Usage: ./list-provider-config.sh YOUR_AZURE_SUBSCRIPTION_ID"
	exit 0
fi

apiVersion="2021-06-07-preview"

url="https://management.azure.com/subscriptions/""$subscriptionId""/providers/Microsoft.Chaos/chaosProviderConfigurations/?api-version=""$apiVersion"

az rest --method get --url "$url"
