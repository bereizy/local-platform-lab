# Mentor's Reference Guide

This document is designed for instructors and mentors guiding students through the Local Platform Lab. It focuses on the **pedagogical goals**, common "stuck points," and the deeper technical context behind the configuration decisions.

## 🎓 Learning Objectives

1.  **Kubernetes Primitives vs. Abstractions**: 
    -   *Goal*: Student understands that `Helm` is just a templating engine generating `Deployments`, `ConfigMaps`, and `Secrets`.
    -   *Exercise*: Have them deploy via Manifests first, then `kubectl delete`, then deploy via Helm. Ask: "What resources were created in both cases?"

2.  **Container Networking & DNS**:
    -   *Goal*: Understanding internal cluster DNS (`svc.cluster.local`) vs.Host networking (`localhost` via Tunnel) vs. Ingress.
    -   *Exercise*: Ask them to `curl` Keycloak from their laptop terminal vs. from inside the generic Postgres pod.

3.  **The "Docker-in-Docker" Problem**:
    -   *Goal*: Understand why we use **Buildah** (Daemonless) instead of mounting `/var/run/docker.sock` (Security nightmare).
    -   *Teaching Point*: Explain that mounting the socket gives the container `root` access to the host node.

---

## 🛑 Common "Stuck Points" & Solutions

### 1. The "Invalid Token" Loop
*Scenario*: Student says "My runner keeps crashing" or "It says unauthorized".
*   **Cause**: Converting the GitLab **Project Token** (Config/Secret) vs. the **Registration Token** (Legacy flow). Or copying the *Example* token from the README.
*   ** Mentor Check**: Ask them to `cat manifests/gitlab-runner-configmap.yaml` and verify the token string matches what is literally shown in their GitLab UI under **Settings > CI/CD > Runners**.

### 2. The "Pending" Service
*Scenario*: "I deployed Keycloak but I can't access it at localhost:8080."
*   **Cause**: The service is isolated. They need to forward the port.
*   **Teaching Moment**: "Kubernetes networks are isolated. `NodePort` or `LoadBalancer` are one way to get in, but for development without `sudo` access, `port-forward` is your best friend. It pipes traffic directly from your laptop to the specific pod or service."
*   **Fix**: `kubectl port-forward -n platform svc/keycloak 8080:8080`

### 3. Registry Connection Refused
*Scenario*: The pipeline fails with `dial tcp 127.0.0.1:8080: connect: connection refused` or similar inside the job.
*   **Cause**: Using `localhost` inside a pod refers to the *pod itself*, not the host Mac.
*   **Mentor Check**: Are they using `host.minikube.internal` (to hit Mac services) or `registry.kube-system...` (to hit the internal registry)?

### 4. Buildah "Driver Not Supported"
*Scenario*: Pipeline fails with storage driver errors.
*   **Cause**: The pod is not running as `privileged: true`.
*   **Fix**: Check `helm/values.yaml` or `gitlab-runner-deployment.yaml`.
*   **Teaching Point**: Building container images requires intricate manipulation of file systems (OverlayFS). Standard containers are blocked from doing this for security.

---

## 🧠 Deep Dive Context (For the Mentor)

### Why Buildah?
We use Buildah because modern Kubernetes environments (OpenShift, GKE Autopilot) often ban Docker Socket mounting. Teaching students to rely on `docker build` inside CI is setting them up for failure in strict enterprise environments.

### Why Minikube Docker Driver?
We use the Docker driver (running K8s nodes as containers) because it has the best performance/compatibility balance on Apple Silicon (ARM64) compared to the QEMU/VMware drivers.

### The "TLS_VERIFY" Variable
In the `buildah-build-template.yml`, we flip `TLS_VERIFY` to false.
*   *Discussion*: "In production, would we do this?" (No). "Why do we do it here?" (Because managing extensive PKI/Certs for a disposable localhost lab is overhead that distracts from the core learning objectives).

---

## 🛠️ Diagnostics Cheat Sheet

If a student is hopelessly broken, run this sequence:

1.  **"Show me the pods"**
    ```bash
    kubectl get pods -A | grep -v Run
    ```
    *(Look for CrashLoopBackOff or Pending)*

2.  **"Check the Port Forward"**
    ```bash
    ps aux | grep "kubectl port-forward"
    ```

3.  **"Can the Runner talk to GitLab?"**
    ```bash
    kubectl exec -it -n gitlab-runner <runner-pod> -- nslookup gitlab.com
    ```
    *(Tests CoreDNS and Internet Access)*

4.  **"Can the Runner talk to the Registry?"**
    ```bash
    kubectl exec -it -n gitlab-runner <runner-pod> -- curl -v http://registry.kube-system.svc.cluster.local
    ```
