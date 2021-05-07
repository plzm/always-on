#!/bin/bash

subscriptionId="$(az account show -o tsv --query 'id')"
resourceGroup="always-on-global"

frontDoorName="pz-ao-at-1"

wafPolicyName="${frontDoorName//-/}"

endpointName="pzaoat1"
originResponseTimeoutSeconds="16"

originGroupName="apims"

securityPolicyName="secpol1"

routeName="defaultRoute"

## GLOBAL

# WAF Policy
#az deployment group create --subscription "$subscriptionId" -n "fd-waf-policy" --verbose \
#	-g "$resourceGroup" --template-file "../templates/fd.waf-policy.json" \
#	--parameters wafPolicyName="$wafPolicyName"

wafPolicyId="$(az network front-door waf-policy show --subscription ""$subscriptionId"" -g ""$resourceGroup"" -n ""$wafPolicyName"" -o tsv --query 'id')"

# FD Profile
#az deployment group create --subscription "$subscriptionId" -n "fd-profile" --verbose \
#	-g "$resourceGroup" --template-file "../templates/fd.profile.json" \
#	--parameters frontDoorName="$frontDoorName"

# FD Endpoint
#az deployment group create --subscription "$subscriptionId" -n "fd-profile-endpoint" --verbose \
#	-g "$resourceGroup" --template-file "../templates/fd.profile-endpoint.json" \
#	--parameters \
#	frontDoorName="$frontDoorName" endpointName="$endpointName" originResponseTimeoutSeconds="$originResponseTimeoutSeconds"

# FD Security Policy
#az deployment group create --subscription "$subscriptionId" -n "fd-security-policy" --verbose \
#	-g "$resourceGroup" --template-file "../templates/fd.security-policy.json" \
#	--parameters \
#	frontDoorName="$frontDoorName" securityPolicyName="$securityPolicyName" wafPolicyId="$wafPolicyId" endpointName="$endpointName"

# FD Origin Group
#az deployment group create --subscription "$subscriptionId" -n "fd-origin-group" --verbose \
#	-g "$resourceGroup" --template-file "../templates/fd.origin-group.json" \
#	--parameters \
#	frontDoorName="$frontDoorName" originGroupName="$originGroupName"

# REGIONAL


originGroupId="$(az afd origin-group show --subscription ""$subscriptionId"" -g ""$resourceGroup"" --profile-name ""$frontDoorName"" --origin-group-name ""$originGroupName"" -o tsv --query 'id')"

# FD Routes
az deployment group create --subscription "$subscriptionId" -n "fd-route" --verbose \
	-g "$resourceGroup" --template-file "../templates/fd.route.json" \
	--parameters \
	frontDoorName="$frontDoorName" endpointName="$endpointName" routeName="$routeName" originGroupId="$originGroupId"

