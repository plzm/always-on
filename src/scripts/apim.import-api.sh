#!/bin/bash

PREFIX="pz-ao"
SUFFIX="27"

subscriptionId="$(az account show -o tsv --query 'id')"
location="eastus2"
resourceGroup="always-on-""$location"
serviceName="$PREFIX""-""$location""-""$SUFFIX"
apiId="aofe"
displayName="AlwaysOn Front End API"
description="AlwaysOn Front End API"
apiVersion="v1"
appGwPipName="$PREFIX""-appgw-""$location"
appGwFqdn="$appGwPipName"".""$location"".cloudapp.azure.com"
servicePath="/"


az apim api import --subscription "$subscriptionId" -g "$resourceGroup" -n "$serviceName" --verbose \
--api-id "$apiId" --display-name "$displayName" --description "$description" \
--api-revision "$apiVersion" --service-url "http://$appGwFqdn" --path "$servicePath" \
--subscription-required false --protocols http https \
--specification-format "OpenApiJson" --specification-path "../workload/alwayson/ao.fe/swagger.json"
