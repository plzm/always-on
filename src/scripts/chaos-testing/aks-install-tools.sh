#!/bin/bash

# Install YQ locally to read YAML and convert JSON
# For GH pipeline: https://mikefarah.gitbook.io/yq/usage/github-action
# https://mikefarah.gitbook.io/yq/
# EXAMPLE USAGE: yq eval '.spec' dns-chaos.error.yaml --tojson --indent 0 > dns-chaos.error.json
YQVERSION=v4.10.0
YQBINARY=yq_linux_amd64
sudo wget https://github.com/mikefarah/yq/releases/download/${YQVERSION}/${YQBINARY} -O /usr/bin/yq && sudo chmod +x /usr/bin/yq
