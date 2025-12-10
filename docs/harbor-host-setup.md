# Setting up Harbor (Host Docker Compose)

As an alternative to the simple Minikube Registry, you can run a full enterprise-grade **Harbor Registry** on your host machine using Docker Compose.

## Why use this?
-   **GUI**: Browse images, view details.
-   **Security**: Vulnerability scanning (Trivy) included.
-   **Persistence**: Easier to manage data on host filesystem.

## Prerequisites
-   **Docker Desktop** (Mac) configured with enough resources (At least 8GB RAM recommended for Minikube + Harbor).
-   **Sudo Access** (Required for the install script).

## Setup
We have provided a helper script to download and install Harbor v2.10.0.

1.  **Run the Setup Script**:
    ```bash
    chmod +x scripts/setup-host-harbor.sh
    ./scripts/setup-host-harbor.sh
    ```
    *Note: You may be prompted for your Mac password (sudo) as the Harbor installer sets up docker networking.*

2.  **Verify Access**:
    -   Open your browser to: `http://localhost:8085`
    -   **Username**: `admin`
    -   **Password**: `Harbor12345`

## Connecting Minikube/Runners to Harbor

Since Harbor is running on the **Host** and the Runner is in **Minikube**, the Runner must address Harbor correctly.

**External URL**: `host.minikube.internal:8085`

### 1. Update your `.gitlab-ci.yml` Variables
```yaml
variables:
  CI_REGISTRY: "host.minikube.internal:8085"
  CI_REGISTRY_USER: "admin"
  CI_REGISTRY_PASSWORD: "Harbor12345"
  # Harbor is running on HTTP, so we must disable TLS verification
  TLS_VERIFY: "false" 
```

### 2. Configure Insecure Registry (Important!)
Since we are running over HTTP, the Buildah container inside the pod might refuse to push.
*(Our default `buildah-build-template.yml` handles this via the `TLS_VERIFY` variable).*

## Stopping/Starting Harbor

The installer creates a `docker-compose.yml` in the `harbor-host/` directory.

**Stop**:
```bash
cd harbor-host
docker-compose down
```

**Start**:
```bash
cd harbor-host
docker-compose up -d
```
