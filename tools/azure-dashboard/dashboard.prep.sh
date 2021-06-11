#!/bin/bash

cp ./Always-On-Clean.json ./Always-On-Test.json

appInsightsResourceIdIn="/subscriptions/e61e4c75-268b-4c94-ad48-237aa3231481/resourceGroups/always-on-global/providers/microsoft.insights/components/pz-ao"
appInsightsResourceIdOut="PROVIDE_APP_INSIGHTS_RESOURCE_ID"

sed -i "s|$appInsightsResourceIdOut|$appInsightsResourceIdIn|g" Always-On-Test.json

cosmosDbAccountResourceIdIn="/subscriptions/e61e4c75-268b-4c94-ad48-237aa3231481/resourceGroups/always-on-global/providers/Microsoft.DocumentDB/databaseAccounts/pz-ao"
cosmosDbAccountResourceIdOut="PROVIDE_COSMOS_DB_ACCOUNT_RESOURCE_ID"

sed -i "s|$cosmosDbAccountResourceIdOut|$cosmosDbAccountResourceIdIn|g" Always-On-Test.json

frontDoorResourceIdIn="/subscriptions/e61e4c75-268b-4c94-ad48-237aa3231481/resourceGroups/always-on-global/providers/Microsoft.Cdn/profiles/pz-ao"
frontDoorResourceIdOut="PROVIDE_FRONT_DOOR_RESOURCE_ID"

sed -i "s|$frontDoorResourceIdOut|$frontDoorResourceIdIn|g" Always-On-Test.json


apimLoc1ResourceIdIn="/subscriptions/e61e4c75-268b-4c94-ad48-237aa3231481/resourceGroups/always-on-eastus2/providers/Microsoft.ApiManagement/service/pz-ao-eastus2-31"
apimLoc1ResourceIdOut="PROVIDE_APIM_REGION_1_RESOURCE_ID"

sed -i "s|$apimLoc1ResourceIdOut|$apimLoc1ResourceIdIn|g" Always-On-Test.json

apimLoc2ResourceIdIn="/subscriptions/e61e4c75-268b-4c94-ad48-237aa3231481/resourceGroups/always-on-westus2/providers/Microsoft.ApiManagement/service/pz-ao-westus2-31"
apimLoc2ResourceIdOut="PROVIDE_APIM_REGION_2_RESOURCE_ID"

sed -i "s|$apimLoc2ResourceIdOut|$apimLoc2ResourceIdIn|g" Always-On-Test.json


appGwLoc1ResourceIdIn="/subscriptions/e61e4c75-268b-4c94-ad48-237aa3231481/resourceGroups/always-on-eastus2/providers/Microsoft.Network/applicationGateways/pz-ao-eastus2"
appGwLoc1ResourceIdOut="PROVIDE_APPGW_REGION_1_RESOURCE_ID"

sed -i "s|$appGwLoc1ResourceIdOut|$appGwLoc1ResourceIdIn|g" Always-On-Test.json

appGwLoc2ResourceIdIn="/subscriptions/e61e4c75-268b-4c94-ad48-237aa3231481/resourceGroups/always-on-westus2/providers/Microsoft.Network/applicationGateways/pz-ao-westus2"
appGwLoc2ResourceIdOut="PROVIDE_APPGW_REGION_2_RESOURCE_ID"

sed -i "s|$appGwLoc2ResourceIdOut|$appGwLoc2ResourceIdIn|g" Always-On-Test.json


aksLoc1ResourceIdIn="/subscriptions/e61e4c75-268b-4c94-ad48-237aa3231481/resourceGroups/always-on-eastus2/providers/Microsoft.ContainerService/managedClusters/pz-ao-eastus2"
aksLoc1ResourceIdOut="PROVIDE_AKS_REGION_1_RESOURCE_ID"

sed -i "s|$aksLoc1ResourceIdOut|$aksLoc1ResourceIdIn|g" Always-On-Test.json

aksLoc2ResourceIdIn="/subscriptions/e61e4c75-268b-4c94-ad48-237aa3231481/resourceGroups/always-on-westus2/providers/Microsoft.ContainerService/managedClusters/pz-ao-westus2"
aksLoc2ResourceIdOut="PROVIDE_AKS_REGION_2_RESOURCE_ID"

sed -i "s|$aksLoc2ResourceIdOut|$aksLoc2ResourceIdIn|g" Always-On-Test.json


ehLoc1ResourceIdIn="/subscriptions/e61e4c75-268b-4c94-ad48-237aa3231481/resourceGroups/always-on-eastus2/providers/Microsoft.EventHub/namespaces/pz-ao-eastus2"
ehLoc1ResourceIdOut="PROVIDE_EH_REGION_1_RESOURCE_ID"

sed -i "s|$ehLoc1ResourceIdOut|$ehLoc1ResourceIdIn|g" Always-On-Test.json

ehLoc2ResourceIdIn="/subscriptions/e61e4c75-268b-4c94-ad48-237aa3231481/resourceGroups/always-on-westus2/providers/Microsoft.EventHub/namespaces/pz-ao-westus2"
ehLoc2ResourceIdOut="PROVIDE_EH_REGION_2_RESOURCE_ID"

sed -i "s|$ehLoc2ResourceIdOut|$ehLoc2ResourceIdIn|g" Always-On-Test.json


akvLoc1ResourceIdIn="/subscriptions/e61e4c75-268b-4c94-ad48-237aa3231481/resourceGroups/always-on-eastus2/providers/Microsoft.KeyVault/vaults/pz-ao-eastus2-31"
akvLoc1ResourceIdOut="PROVIDE_AKV_REGION_1_RESOURCE_ID"

sed -i "s|$akvLoc1ResourceIdOut|$akvLoc1ResourceIdIn|g" Always-On-Test.json

akvLoc2ResourceIdIn="/subscriptions/e61e4c75-268b-4c94-ad48-237aa3231481/resourceGroups/always-on-westus2/providers/Microsoft.KeyVault/vaults/pz-ao-westus2-31"
akvLoc2ResourceIdOut="PROVIDE_AKV_REGION_2_RESOURCE_ID"

sed -i "s|$akvLoc2ResourceIdOut|$akvLoc2ResourceIdIn|g" Always-On-Test.json


dashboardNameIn="Always-On"
dashboardNameOut="Always-On-Test"

sed -i "s|$dashboardNameIn|$dashboardNameOut|g" Always-On-Test.json
