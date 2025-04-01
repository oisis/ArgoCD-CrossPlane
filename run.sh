#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

printf "${GREEN}Adding ArgoCD Helm repo${NC}\n"
helm repo add argocd https://argoproj.github.io/argo-helm

printf "${GREEN} Update Helm local repos cache${NC}\n"
helm repo update

printf "${GREEN}Installing ArgoCD with Helm${NC}\n"
helm install argocd argocd/argo-cd --version 7.8.18 \
  -f ./argocd/bootstrap/helm/argocd-values.yaml \
  --create-namespace \
  -n argocd

printf "${GREEN}Applying K8s manifests to finish ArgoCD bootstrap${NC}\n"
kubectl apply -f ./argocd/bootstrap/manifests/

ARGOPASS=$(argocd admin initial-password -n argocd | head -n 1)
printf "${GREEN}ArgoCD admin password${NC}: ${RED}${ARGOPASS}${NC}\n"

printf "${GREEN}To get access to ArgoCD UI run command:${NC}\n"
printf "    kubectl port-forward svc/argocd-server -n argocd 8080:443\n"
printf "${GREEN}Open http://localhost:8080 in webbrowser${NC}\n"

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
  --from-literal=creds="$(printf '[default]\naws_access_key_id = %s\naws_secret_access_key = %s' "$AWS_ACCESS_KEY_ID" "$AWS_SECRET_ACCESS_KEY")"
