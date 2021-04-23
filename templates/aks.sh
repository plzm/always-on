#!/bin/bash

az aks create -g always-on-5 -n ao-aks-mi1 \
	--enable-managed-identity --assign-identity "/subscriptions/e61e4c75-268b-4c94-ad48-237aa3231481/resourcegroups/always-on-5/providers/Microsoft.ManagedIdentity/userAssignedIdentities/pz-ao-uami"

