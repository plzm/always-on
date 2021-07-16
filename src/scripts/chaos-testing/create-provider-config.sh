#!/bin/bash

subscriptionId=$1
chaosProviderType=$2

echo $subscriptionId
echo $chaosProviderType

if [ -z "$subscriptionId" ] || [ -z "$chaosProviderType" ]
then
	echo "Usage: ./create-provider-config.sh YOUR_AZURE_SUBSCRIPTION_ID YOUR_CHAOS_PROVIDER_TYPE"
	exit 0
fi

apiVersion="2021-06-07-preview"

url="https://management.azure.com/subscriptions/""$subscriptionId""/providers/Microsoft.Chaos/chaosProviderConfigurations/""$chaosProviderType""?api-version=""$apiVersion"

chaosProviderConfig="
{
  \"properties\": {
    \"enabled\": true,
    \"providerConfiguration\": {
      \"type\": \"""$chaosProviderType""\"
    }
  }
}"

az rest --method put --url "$url" --body "$chaosProviderConfig"
