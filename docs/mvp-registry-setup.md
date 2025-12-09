# MVP: Using Minikube Internal Registry

For locally testing the pipeline without an external registry (GitLab/Harbor), we use the Minikube `registry` addon.

## 1. Enable Registry
Ensure the registry addon is enabled (this should already be done):
```bash
minikube addons enable registry
```

## 2. Network Details
- **Internal URL**: `registry.kube-system.svc.cluster.local`
- **Port**: 80 (HTTP)
- **External/Host Access**: `localhost:56511` (Mapped by Docker driver)

## 3. Configuring the CI Job
In your `.gitlab-ci.yml`, configure the variables to point to this internal registry and disable TLS verification:

```yaml
variables:
  CI_REGISTRY: "registry.kube-system.svc.cluster.local"
  CI_REGISTRY_USER: "unused"      # Minikube registry doesn't enforce auth by default
  CI_REGISTRY_PASSWORD: "unused"
  TLS_VERIFY: "false"             # Required because it runs on HTTP
```

## 4. Verifying Images
To verify an image was pushed, you can curl the catalog from your terminal (host):

```bash
curl http://localhost:56511/v2/_catalog
```
