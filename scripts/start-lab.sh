#!/bin/bash
set -e

echo "🚀 Starting Local Platform Lab..."

# 1. Start Minikube
# We use existing profile if present, preserving data/PVCs
minikube start --driver=docker

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

# 4. Deploy GitLab Runner
echo ""
echo "❓ How would you like to deploy the GitLab Runner?"
echo "   1) Manual Manifests (Great for learning k8s internals)"
echo "   2) Helm Chart (Standard production approach - Requires Helm installed)"
echo "   3) Skip Runner Deployment (I will do it manually later)"
read -p "   Select [1-3]: " RUNNER_CHOICE

case $RUNNER_CHOICE in
    1)
        echo "📄 Applying Kubernetes Manifests for Runner..."
        kubectl apply -f manifests/namespace.yaml
        kubectl apply -f manifests/rbac.yaml
        
        if [ -f "manifests/gitlab-runner-configmap.yaml" ]; then
            kubectl apply -f manifests/gitlab-runner-configmap.yaml
        fi
        if [ -f "manifests/gitlab-runner-deployment.yaml" ]; then
            kubectl apply -f manifests/gitlab-runner-deployment.yaml
        fi
        ;;
    2)
        echo "⎈ Deploying via Helm..."
        if ! command -v helm &> /dev/null; then
            echo "❌ Helm not found. Please install helm first (brew install helm)."
        else
            helm repo add gitlab https://charts.gitlab.io
            helm repo update
            # Ensure namespace
            kubectl create namespace gitlab-runner --dry-run=client -o yaml | kubectl apply -f -
            # Upgrade/Install
            helm upgrade --install gitlab-runner gitlab/gitlab-runner --namespace gitlab-runner -f helm/values.yaml
        fi
        ;;
    *)
        echo "⏭️  Skipping Runner Deployment."
        ;;
esac

# 5. Final Status
echo ""
echo "✅ Lab Environment is Ready!"
echo "---------------------------------------------------"
echo "🔍 Status:"
kubectl get pods -A | grep -E "(platform|gitlab-runner)"
echo "---------------------------------------------------"
echo "⚠️  ACTION REQUIRED: Network Access"
echo "   To access Keycloak at http://localhost:8080, run this in a separate terminal:"
echo "   kubectl port-forward -n platform svc/keycloak 8080:8080"
echo ""
