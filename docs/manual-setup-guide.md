# Manual Setup & Deployment Guide

This guide provides a step-by-step walkthrough to stand up the Local Platform Lab manually. It explains the purpose of each command and the order of operations required to ensure dependencies (like the Registry and Storage) are ready before the Application services start.

## Prerequisites
-   **Docker Desktop** (Running)
-   **Minikube** (`brew install minikube`)
-   **Kubectl** (`brew install kubectl`)

---

## Step 1: Initialize the Infrastructure

**Command:**
```bash
minikube start --driver=docker --arch=arm64
```
**Why?**
We typically use the `docker` driver on macOS to run Kubernetes inside a container. The `--arch=arm64` flag ensures that the Minikube VM matches the Apple Silicon architecture, preventing performance emulation issues.

---

## Step 2: Enable the Internal Registry

**Command:**
```bash
minikube addons enable registry
```

**Why?**
By default, Kubernetes doesn't have a place to store container images you build. We enable this addon to create a local Docker Registry inside the cluster (`localhost:5000` intra-cluster). This allows your CI pipelines to push images locally without needing credentials for an external service like Docker Hub or GitLab.com.

---

## Step 3: Deploy Platform Services (Identity & Data)

**Order matters here.** We need the namespace first, then the database, then the identity provider.

### 3.1 Create Namespace
```bash
kubectl apply -f manifests/platform/00-namespace.yaml
```
*Creates the logical isolation `platform` for our shared services.*

### 3.2 Deploy Postgres
```bash
kubectl apply -f manifests/platform/01-postgres.yaml
```
*Deploys the Database. This must happen before Keycloak because Keycloak needs to connect to the DB on startup. This manifest also initializes the `keycloak` and `appdb` databases.*

### 3.3 Deploy Keycloak
```bash
kubectl apply -f manifests/platform/02-keycloak.yaml
```
*Deploys the Identity Provider. It will connect to the Postgres service deployed in the previous step.*

---

## Step 4: Configure & Deploy the CI Runner

### 4.1 Create Runner Namespace & RBAC
```bash
kubectl apply -f manifests/namespace.yaml
kubectl apply -f manifests/rbac.yaml
```
*Sets up the `gitlab-runner` namespace and grants the necessary permissions (RoleBasedAccessControl) so the runner can create/delete pods to run your build jobs.*

### 4.2 Configure the Runner
**Action Required:** Open `manifests/gitlab-runner-configmap.yaml` and update the registration token if proper connectivity to GitLab.com is desired.
*(If just testing infrastructure, you can skip editing, but the runner pod will log authentication errors).*

```bash
kubectl apply -f manifests/gitlab-runner-configmap.yaml
```

### 4.3 Deploy the Runner
```bash
kubectl apply -f manifests/gitlab-runner-deployment.yaml
```
*Spins up the actual Runner pod. It reads the configuration from the ConfigMap applied above.*

---

## Step 5: Establish Network Connectivity

**Command:**
```bash
sudo minikube tunnel
```
*(Keep this terminal open)*

**Why?**
Keycloak is exposed as a `LoadBalancer` service. In a real cloud (AWS/GCP), this gives you a Public IP. On Minikube, the "LoadBalancer" stays in "Pending" state forever unless you run `minikube tunnel`. This command creates a network route from your Mac's `localhost` to the Service inside the cluster.

---

## Step 6: Validation

Open a new terminal and run:

```bash
# Check if all pods are running
kubectl get pods -A | grep -E "(platform|gitlab-runner)"

# Test Keycloak (Should return 200 OK)
curl -I http://localhost:8080
```

You are now ready to run pipelines!
