# Local Platform Lab Overview

## Architecture

This environment simulates a full container lifecycle platform locally on your Apple Silicon Mac. It consists of:

1.  **Minikube**: Acts as the local Kubernetes cluster hosting the infrastructure.
2.  **GitLab Runner**: Deployed inside Minikube, configured with the Kubernetes executor. It polls a GitLab instance (SaaS or self-hosted) for jobs.
3.  **Buildah**: Used within CI pipelines to build OCI-compliant container images without requiring a Docker daemon (daemonless build).
4.  **Harbor / GitLab Registry**: The target container registry for storing built images.
5.  **Application Deployment**: The runner deploys the built images back into the Minikube cluster.

## Design Decisions

### Why Buildah?
We chose Buildah over Kaniko or Docker-in-Docker (DinD) for the following reasons:
-   **Security**: Buildah does not require a daemon running as root. While we are using `privileged: true` for the runner to facilitate mounting, Buildah itself offers a more granular approach to unprivileged builds in the future compared to the heavy requirement of DinD.
-   **Compatibility**: It produces OCI-compliant images effectively.
-   **Performance**: It avoids the layer caching complexities and potential security risks associated with exposing the host Docker socket.

### Apple Silicon Considerations
-   The setup assumes ARM64 architecture.
-   `quay.io/buildah/stable` and `gitlab/gitlab-runner` have multi-arch support, ensuring smooth operation on M1/M2/M3 chips.
