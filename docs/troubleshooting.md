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

### Registry / Image Push Issues
-   **Symptom**: `x509: certificate signed by unknown authority` or `http: server gave HTTP response to HTTPS client`.
-   **Fix**:
    1. The Minikube registry is **insecure (HTTP)**.
    2. Ensure your `buildah` command uses the flag `--tls-verify=false`.
    3. Ensure your CI variable `TLS_VERIFY` is set to `"false"`.
    4. Verify the registry is actually running:
       ```bash
       kubectl get pods -n kube-system -l kubernetes.io/minikube-addons=registry
       ```

### Keycloak Not Accessible (Connection Refused)
-   **Symptom**: Browsing to `http://127.0.0.1:8080` fails.
-   **Fix**:
    1. **Port Forwarding Required**: The Keycloak service is isolated inside the cluster. You must forward a local port to access it.
       Run this in a separate terminal and keep it open:
       ```bash
       kubectl port-forward -n platform svc/keycloak 8080:8080
       ```
    2. **Check Port Conflicts**: Ensure no other service (like a local Tomcat or Jenkins) is already using port 8080 on your Mac.

### Postgres Connection Failures
-   **Symptom**: App containers cannot connect to DB `postgres.platform.svc.cluster.local`.
-   **Fix**:
    1. Check if the Platform namespace pods are running:
       ```bash
       kubectl get pods -n platform
       ```
    2. Verify DNS resolution from within the app pod:
       ```bash
       nslookup postgres.platform.svc.cluster.local
       ```
    3. Verify credentials (default is `appuser`/`apppassword` for the application database).

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

# Check platform services (Keycloak/DB)
kubectl get pods -n platform

# view runner logs
kubectl logs -l app=gitlab-runner -n gitlab-runner --tail=100 -f

# Check Minikube Tunnel Status
ps aux | grep "minikube tunnel"
```
