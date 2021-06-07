#!/bin/bash

collectionUrlGetProfile="https://raw.githubusercontent.com/plzm/always-on/main/tools/postman/Always-On-Get-Profile.postman_collection.json"
collectionUrlPostProfile="https://raw.githubusercontent.com/plzm/always-on/main/tools/postman/Always-On-Post-Profile.postman_collection.json"
collectionUrlPostProgress="https://raw.githubusercontent.com/plzm/always-on/main/tools/postman/Always-On-Post-Progress.postman_collection.json"

apiEndpoint="https://pz-ao.z01.azurefd.net/api/"
iterations=100

docker pull postman/newman

# This runs sequentially but of course can be split into multiple scripts and run simultaneously.
docker run -t postman/newman run "$collectionUrlGetProfile" --env-var "ApiEndpoint=$apiEndpoint" -n $iterations -k --reporters json --reporter-json-export ./get-profile.json
docker run -t postman/newman run "$collectionUrlPostProfile" --env-var "ApiEndpoint=$apiEndpoint" -n $iterations -k --reporters json --reporter-json-export ./post-profile.json
docker run -t postman/newman run "$collectionUrlPostProgress" --env-var "ApiEndpoint=$apiEndpoint" -n $iterations -k --reporters json --reporter-json-export ./post-progress.json
