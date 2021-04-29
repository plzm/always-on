#!/bin/bash

# ##########
# BYO Kubelet MI preview

az feature register --namespace Microsoft.ContainerService -n CustomKubeletIdentityPreview
# Gives this message: Once the feature 'CustomKubeletIdentityPreview' is registered, invoking 'az provider register -n Microsoft.ContainerService' is required to get the change propagated
# Wait...

# ... until this shows "Registered"
az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/CustomKubeletIdentityPreview')].{Name:name,State:properties.state}"

# Then run
az provider register --namespace Microsoft.ContainerService
# ##########
