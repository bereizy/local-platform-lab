#!/bin/bash
set -e

echo "🚀 Starting Local Platform Lab..."

# 1. Start Minikube
# We use existing profile if present, preserving data/PVCs
minikube start --driver=docker --arch=arm64

# 2. Ensure Registry is up
echo "📦 Verifying Registry..."
minikube addons enable registry

# 3. Apply/Refresh Manifests
# This ensures any changes to YAMLs are applied, and restores state if this was a fresh 'delete'
echo "📄 Applying Kubernetes Manifests..."

# Platform Services (Namespaces, Postgres, Keycloak)
if [ -d "manifests/platform" ]; then
    kubectl apply -f manifests/platform/
fi

# GitLab Runner (Namespace, RBAC, Config, Deployment)
kubectl apply -f manifests/namespace.yaml
kubectl apply -f manifests/rbac.yaml

# Only apply runner deployment/config if they exist (they should)
if [ -f "manifests/gitlab-runner-configmap.yaml" ]; then
    kubectl apply -f manifests/gitlab-runner-configmap.yaml
fi
if [ -f "manifests/gitlab-runner-deployment.yaml" ]; then
    kubectl apply -f manifests/gitlab-runner-deployment.yaml
fi

# 4. Final Status
echo ""
echo "✅ Lab Environment is Ready!"
echo "---------------------------------------------------"
echo "🔍 Status:"
kubectl get pods -A | grep -E "(platform|gitlab-runner)"
echo "---------------------------------------------------"
echo "⚠️  ACTION REQUIRED: Network Tunnel"
echo "   To access Keycloak at http://localhost:8080, run this in a separate terminal:"
echo "   sudo minikube tunnel"
echo ""
