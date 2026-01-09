# Setup Guide

## Prerequisites
- Azure CLI
- kubectl
- Helm 3.x
- Docker

## Steps

1. Run Azure setup: `./scripts/setup-azure.sh`
2. Install Argo CD: `./scripts/setup-argocd.sh`
3. Configure Azure DevOps pipeline
4. Push code to trigger deployment