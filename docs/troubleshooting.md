# Troubleshooting Guide

## Common Issues

### Runner Registration Fails
-   **Symptom**: Runner logs show 401 Unauthorized or "invalid token".
-   **Fix**: 
    1. Verify the `token` in `manifests/gitlab-runner-configmap.yaml`. It must match the registration token from GitLab, not a personal access token.
    2. If you updated the ConfigMap, restart the runner pod:
       ```bash
       kubectl rollout restart deployment gitlab-runner -n gitlab-runner
       ```

### Buildah Storage Errors
-   **Symptom**: "driver not supported", "permission denied" on `/var/lib/containers`.
-   **Fix**:
    1. Ensure the `gitlab-runner` deployment has `privileged: true`.
    2. Check that the ConfigMap correctly defines the `[runners.kubernetes.volumes]` for `containers-storage` mounting to `/var/lib/containers`.
    3. Ensure `STORAGE_DRIVER` variable is set to `vfs` in the CI job if overlayfs gives issues on the specific kernel.

### Harbor Authentication
-   **Symptom**: `buildah login` fails or push fails with 401.
-   **Fix**:
    1. Manually test credentials:
       ```bash
       docker login <HARBOR_URL> -u <USER> -p <PASS>
       ```
    2. Ensure the `harbor-cred` secret exists in the application namespace if you are pulling images, or that the CI variables `$CI_REGISTRY_USER` and `$CI_REGISTRY_PASSWORD` are correct in GitLab settings.

### Minikube Networking
-   **Symptom**: Runner cannot reach GitLab or Harbor.
-   **Fix**:
    -   If GitLab/Harbor is running on localhost (host machine), use `host.minikube.internal` instead of `localhost` or `127.0.0.1` in your URLs.
    -   Check DNS resolution inside the pod:
        ```bash
        kubectl exec -it <runner-pod> -n gitlab-runner -- nslookup gitlab.com
        ```

## Debug Commands

```bash
# Check all pods in runner namespace
kubectl get pods -n gitlab-runner -o wide

# view runner logs
kubectl logs -l app=gitlab-runner -n gitlab-runner --tail=100 -f

# Describe pod to see mount/permission issues
kubectl describe pod <pod-name> -n gitlab-runner
```
