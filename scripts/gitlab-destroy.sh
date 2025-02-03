#!/bin/bash
# gitlab-destroy.sh
# uninstalls gitLab from cluster.

set -e  # exit immediately if a command exits non-zero status

# if you are not me, replace <cluster-name> and <region> with your own EKS cluster name and region.
echo "Updating kubeconfig..."
aws eks update-kubeconfig --name aws-kubernetes-cluster --region us-east-1

# uninstall gitLab
echo "Uninstalling GitLab..."
helm uninstall gitlab --namespace gitlab

echo "Deleting GitLab namespace..."
kubectl delete namespace gitlab

echo "GitLab has been successfully uninstalled."
