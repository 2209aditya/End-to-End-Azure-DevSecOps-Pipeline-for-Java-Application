#!/bin/bash
set -e

echo "Installing Argo CD..."

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for Argo CD to be ready..."
kubectl wait --for=condition=ready pod --all -n argocd --timeout=300s

echo "Getting admin password..."
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

echo "
Done! Access UI with: kubectl port-forward svc/argocd-server -n argocd 8080:443"