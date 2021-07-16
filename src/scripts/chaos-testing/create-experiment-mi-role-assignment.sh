#!/bin/bash

subscriptionId=$1
experimentResourceGroup=$2
experimentName=$3
targetResourceGroup=$4
rbacRoleName=$5

if [ -z "$subscriptionId" ] || [ -z "$experimentResourceGroup" ] || [ -z "$experimentName" ] || [ -z "$targetResourceGroup" ]
then
	echo "Usage: ./create-exp-mi-role-assignment.sh YOUR_AZURE_SUBSCRIPTION_ID EXPERIMENT_RESOURCE_GROUP_NAME EXPERIMENT_NAME TARGET_RESOURCE_GROUP_NAME RBAC_ROLE_NAME"
	exit 0
fi

if [ -z "$rbacRoleName" ]
then
  rbacRoleName="Contributor"
fi

apiVersion="2021-06-07-preview"

# Get Target Resource Group ID
targetRGResourceId="$(az group show --name ""$targetResourceGroup"" -o tsv --query 'id')"

# Get Experiment Principal ID
url="https://management.azure.com/subscriptions/""$subscriptionId""/resourceGroups/""$experimentResourceGroup""/providers/Microsoft.Chaos/chaosExperiments/""$experimentName""?api-version=""$apiVersion"
experimentPrincipalId="$(az rest --method get --url ""$url"" -o tsv --query 'identity.principalId')"

az role assignment create --role "$rbacRoleName" --scope "$targetRGResourceId" --assignee-object-id "$experimentPrincipalId" --assignee-principal-type "ServicePrincipal"
