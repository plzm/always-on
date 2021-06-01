#!/bin/bash

PREFIX="pz-ao"
SUFFIX="27"

subscriptionId="$(az account show -o tsv --query 'id')"
location="eastus2"
resourceGroup="always-on-""$location"
clusterName="pz-ao-""$location"

az deployment group create --subscription "$subscriptionId" -n "aks" --verbose -c \
	-g "$resourceGroup" --template-file "../infra-deploy/templates/aks.cluster.json" \
	--parameters location="$location" k8sversion="1.20.5" clusterName="pz-ao-eastus2" dnsPrefix="pzaoeastus2" managedIdentityType="UserAssigned" identityResourceId="/subscriptions/""$subscriptionId""/resourcegroups/always-on-eastus2/providers/Microsoft.ManagedIdentity/userAssignedIdentities/pz-ao-eastus2" identityClientId="9742b29b-2435-4ef2-a790-8a96e38e2a86" identityObjectId="d733fd13-4785-4bd4-995f-f141db7a9cc8" availabilityZones="1,2,3" nodeResourceGroup="always-on-eastus2-pz-ao-eastus2" nodeCount=1 enableNodeAutoscale=true nodeCountMin=1 nodeCountMax=10 nodeVmSize="Standard_DS2_v2" osDiskSizeGB=60 nodeAdminUsername="pelazem" sshRSAPublicKey="ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAg+4FzJlW5nqUa798vqYGanooy5HvSyG8sS6KjPu0sJAf+fkP6qpHY8k1m2/Z9Mahv2Y0moZDiVRHFMGH8qZU+AlYdvjGyjxHcIzDnsmHcV2ONxEiop4KMJLwecHUyf95ogicB1QYfK/6Q8pL9sDlXt8bAcSh6iP0u2d1g9QJaON2aniOpzn68xnKdGT974i7JQLN0SjaPiidZ2prc0cSIMBN26tGV7at2Jh5FIb1Jv8fXHnZebD/vgLilfCqLbuQjTpDVCskZ+OUAyvlBko3gBjRgd/jBprMqCpFLoGUBVkSSR0IkjTj2A6n2XyCyYRMFYrVrjwyU8I+IvO/6zJSEw== pelazem" subnetResourceId="/subscriptions/""$subscriptionId""/resourceGroups/always-on-eastus2/providers/Microsoft.Network/virtualNetworks/pz-ao-eastus2/subnets/app" networkPlugin=kubenet serviceCidr=10.1.0.0/16 dnsServiceIp=10.1.0.10 podCidr=10.241.0.0/16 dockerBridgeCidr=172.17.0.1/16 podIdentityEnabled=true podIdentityKubenetEnabled=true podIdentityNamespace="default" podIdentityBindingSelector="pz-ao-eastus2-binding"
