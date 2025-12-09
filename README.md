# Local Platform Lab

A comprehensive simulation environment for running a local Kubernetes-based CI/CD platform on Apple Silicon.

## What is this?
This repository provides the infrastructure-as-code (Kubernetes manifests) and documentation to set up a robust CI/CD pipeline locally. It deploys a GitLab Runner into Minikube, configured to use **Buildah** for building OCI container images without a Docker daemon, and pushes them to a registry (GitLab Container Registry or Harbor).

## Problems Solved
-   **Test builds locally**: Validate CI pipelines entirely on your machine before pushing to shared infrastructure.
-   **Daemonless Builds**: Demonstrates how to use Buildah in Kubernetes, avoiding the security pitfalls of Docker-in-Docker (DinD).
-   **Apple Silicon Support**: All configurations are tuned for ARM64 architecture (M1/M2/M3).

## Prerequisites
1.  **Docker Desktop** (for Mac)
2.  **Minikube**: `brew install minikube`
3.  **Kubectl**: `brew install kubectl`
4.  **Helm** (optional)

## High-Level Usage

1.  **Start Minikube**:
    ```bash
    minikube start --driver=docker
    ```

2.  **Configure & Apply**:
    -   Edit `manifests/gitlab-runner-configmap.yaml` with your GitLab Runner Registration Token.
    -   Apply all manifests: `kubectl apply -f manifests/` (ensure you create the namespace first via `manifests/namespace.yaml`).

3.  **Define Pipeline**:
    -   Use the templates in `ci-templates/` in your project's `.gitlab-ci.yml` to start building with Buildah.

See [docs/implementation.md](docs/implementation.md) for the detailed step-by-step setup guide.
