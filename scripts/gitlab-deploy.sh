#!/bin/bash
# gitlab-deploy.sh
# Deploys (or upgrades) GitLab using Helm.

set -e

# Update kubeconfig
aws eks update-kubeconfig --name aws-kubernetes-cluster --region us-east-1

# Ensure the 'gitlab' namespace exists; create it if necessary.
if ! kubectl get namespace gitlab >/dev/null 2>&1; then
  echo "Namespace 'gitlab' does not exist. Creating it..."
  kubectl create namespace gitlab
else
  echo "Namespace 'gitlab' already exists."
fi

# Deploy or upgrade GitLab using the provided Helm chart and values.
helm upgrade --install gitlab gitlab/gitlab \
  --namespace gitlab \
  -f ../manifests/gitlab-values.yaml

echo "GitLab deployment/upgrade complete."
