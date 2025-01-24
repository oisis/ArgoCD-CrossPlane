#!/bin/bash

GREEN='\033[0;32m'
NC='\033[0m'

printf "${GREEN}Create AWS credentials for CrossPlane:${NC}\n"
if [ -z "${AWS_ACCESS_KEY_ID}" ]; then
  read -p "Provide a value for the variable AWS_ACCESS_KEY_ID: " AWS_ACCESS_KEY_ID
fi

if [ -z "${AWS_SECRET_ACCESS_KEY}" ]; then
  read -p "Provide a value for the variable AWS_SECRET_ACCESS_KEY: " AWS_SECRET_ACCESS_KEY
fi

if ! kubectl get namespace crossplane-system &> /dev/null; then
  kubectl create namespace crossplane-system
  echo "The namespace crossplane-system has been created."
fi

kubectl create secret generic aws-secret \
  --namespace crossplane-system \
  --from-literal=creds="$(echo "[default]\naws_access_key_id = ${AWS_ACCESS_KEY_ID}\naws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}")"
