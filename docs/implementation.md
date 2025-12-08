# Implementation Guide

## Prerequisites
-   Docker Desktop (for Mac)
-   Minikube (`brew install minikube`)
-   Kubectl (`brew install kubectl`)
-   Helm (optional, but good to have)

## 1. Start Minikube
On Apple Silicon, use the `docker` driver for best compatibility:
```bash
minikube start --driver=docker --arch=arm64
```

## 2. Apply Manifests
Navigate to the repository root and apply the manifests in order:

```bash
# Create Namespace
kubectl apply -f manifests/namespace.yaml

# Create RBAC roles
kubectl apply -f manifests/rbac.yaml

# Create Secret for Harbor (Customize first!)
# See basic usage below or edit manifests/harbor-registry-secret.yaml
kubectl create secret docker-registry harbor-cred \
  --docker-server=<HARBOR_URL> \
  --docker-username=<USER> \
  --docker-password=<PASS> \
  --docker-email=none@example.com \
  -n gitlab-runner

# Create ConfigMap
# IMPORTANT: Edit manifests/gitlab-runner-configmap.yaml and replace "YOUR_REGISTRATION_TOKEN_HERE" 
# with your actual GitLab runner registration token from your project Settings -> CI/CD -> Runners.
kubectl apply -f manifests/gitlab-runner-configmap.yaml
```

## 3. Deploy Runner
```bash
kubectl apply -f manifests/gitlab-runner-deployment.yaml
```

## 4. Verify Installation
Check if the runner pod is up and running:
```bash
kubectl get pods -n gitlab-runner
```
Check logs to see if it registered successfully:
```bash
kubectl logs -f -l app=gitlab-runner -n gitlab-runner
```

## 5. Configure Buildah in GitLab CI
Include the template in your `.gitlab-ci.yml`:

```yaml
include:
  - project: 'path/to/local-platform-lab'
    file: '/ci-templates/buildah-build-template.yml'

build:
  extends: .build_image_template
  stage: build
```
