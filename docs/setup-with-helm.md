# Deploying GitLab Runner with Helm

This guide explains how to deploy the GitLab Runner using the official Helm Chart, which is the standard method for production Kubernetes environments.

## Prerequisites
1.  **Helm Installed**:
    ```bash
    brew install helm
    ```
2.  **Minikube Cluster Running**:
    ```bash
    ./scripts/start-lab.sh
    ```
    *(Note: This deployment method can replace Step 4 of the Manual Setup Guide).*

## Step 1: Add the GitLab Helm Repository

Tell Helm where to find the GitLab charts.

```bash
helm repo add gitlab https://charts.gitlab.io
helm repo update
```

## Step 2: Configure the Values

We have provided a pre-configured values file at `helm/values.yaml`. This file ensures that:
-   The runner is configured to use **Buildah** (default image `quay.io/buildah/stable`).
-   **Privileged mode** is enabled (required for building images inside containers).
-   Essential storage volumes (`/var/lib/containers`) are mounted.

**Action Required**:
Open `helm/values.yaml` and replace `YOUR_REGISTRATION_TOKEN_HERE` with your actual GitLab runner registration token.

## Step 3: Install the Chart

Deploy the runner into the `gitlab-runner` namespace.

```bash
# Ensure namespace exists
kubectl create namespace gitlab-runner --dry-run=client -o yaml | kubectl apply -f -

# Install (or Upgrade) the release
helm upgrade --install gitlab-runner gitlab/gitlab-runner \
  --namespace gitlab-runner \
  -f helm/values.yaml
```

## Step 4: Verify Deployment

Check that the runner pod has started successfully:

```bash
kubectl get pods -n gitlab-runner
```

You should see output similar to:
```
NAME                             READY   STATUS    RESTARTS   AGE
gitlab-runner-5d4f7c8b9-xyz12    1/1     Running   0          30s
```

## Cleaning Up
To remove the registry installed via Helm:

```bash
helm uninstall gitlab-runner -n gitlab-runner
```
