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


### Deployment Options

You can install the GitLab Runner using one of two methods:

**Option A: The Learning Path (Manual Manifests)**
Great for understanding Kubernetes concepts (ConfigMaps, Deployments, RBAC) deeply.
-   Follow [docs/manual-setup-guide.md](docs/manual-setup-guide.md).

**Option B: The Standard Path (Helm Chart)**
Uses the official GitLab Helm Chart. Best for mirroring production setups.
-   Follow [docs/setup-with-helm.md](docs/setup-with-helm.md).

## Quick Start (Automated Script)
The provided script is interactive and handles the heavy lifting.

```bash
chmod +x scripts/start-lab.sh
./scripts/start-lab.sh
```

## Documentation Index

**Foundation**
*   [Platform Architecture & Context](docs/platform-context.md) - **Start Here**. What are we building?
*   [Network Architecture](docs/network-diagram.md) - Topology and Port Mappings.
*   [Iterative Design Philosophy](docs/iterative-design-philosophy.md) - **Required Reading**. Why we build layer-by-layer.

**Guides**
*   [Manual Setup Guide](docs/manual-setup-guide.md) - The "Hard Way" (Deep Learning).
*   [Helm Setup Guide](docs/setup-with-helm.md) - The "Standard Way" (Production style).
*   [MVP Registry Setup](docs/mvp-registry-setup.md) - Using the internal Minikube registry.
*   [Host-Based Harbor](docs/harbor-host-setup.md) - Using a full Enterprise Registry (Optional).

**Advanced & Operations**
*   [Automated Keycloak Import](docs/advanced-keycloak-import.md) - Configuration as Code for Identity.
*   [Advanced Roadmap](docs/advanced-roadmap.md) - Next steps (Ingress, GitOps, Policies).
*   [Troubleshooting](docs/troubleshooting.md) - Common issues and fixes.
*   [Mentor Guide](docs/mentor-guide.md) - For instructors (Pedagogy & Teaching Points).

## Project Structure
*   `manifests/`: Raw Kubernetes YAML files.
*   `helm/`: Values file for Helm deployments.
*   `functions/`: Helper scripts (if applicable).
*   `ci-templates/`: Copy-pasteable GitLab CI jobs for Buildah.

See [docs/implementation.md](docs/implementation.md) for the original implementation notes.
