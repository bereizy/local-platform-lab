# Roadmap for Advanced Engineers

Congratulations! If you have fully deployed the Local Platform Lab, automated your configuration imports, and are getting bored, you are ready to level up.

This document outlines the "Next Logical Steps" in platform engineering. These are not required for the basic lab, but they represent the technologies and patterns you will encounter in real-world enterprise Kubernetes environments.

---

## Level 1: Networking & Access (Stop Port-Forwarding)

**The Problem**: Running `kubectl port-forward` for every service (Keycloak, Harbor, App1, App2) is tedious and fragile.
**The Solution**: **Ingress Controllers**.

1.  **Enable Ingress**:
    ```bash
    minikube addons enable ingress
    ```
2.  **Create Ingress Resources**: Instead of `LoadBalancer` services, write an `Ingress` manifest that routes traffic based on hostnames.
    ```yaml
    rules:
      - host: keycloak.lab.local
        http: ...
      - host: registry.lab.local
        http: ...
    ```
3.  **Local DNS**: Edit your `/etc/hosts` file (on your Mac) to point these domains to `127.0.0.1` (with `minikube tunnel` running).

*Result*: You access services at `http://keycloak.lab.local` like a pro.

---

## Level 2: GitOps (Stop `kubectl apply`)

**The Problem**: You change a YAML file but forget to run `kubectl apply`. Your git repo says one thing, but the cluster does another ("Drift").
**The Solution**: **ArgoCD**.

1.  **Install ArgoCD**: Deploy ArgoCD into your Minikube cluster.
2.  **Connect Repo**: Point an Argo Application at your `local-platform-lab` git repository path `manifests/platform`.
3.  **Sync**: Commit a change to Git (e.g., change replica count of Keycloak). Watch ArgoCD automatically detect it and sync the cluster.

*Result*: Your Git repository becomes the Single Source of Truth.

---

## Level 3: Secret Management (Stop Plaintext Passwords)

**The Problem**: You have `POSTGRES_PASSWORD: "lab-password"` committed in plain text in your YAML files. This is a security violation.
**The Solution**: **Sealed Secrets** or **External Secrets**.

1.  **Choose a Tool**: Bitnami Sealed Secrets is easiest for this lab.
2.  **Encrypt**: Use the `kubeseal` CLI to encrypt your secret locally. It generates a `SealedSecret` custom resource safe to commit to Git.
3.  **Deploy**: The controller inside the cluster decrypts it into a regular Secret.

*Result*: You can safely push your entire configuration to a public GitHub repo without leaking credentials.

---

## Level 4: Observability (Stop Guessing)

**The Problem**: Keycloak is slow. Is it the CPU? Is it the Database? Is it Java garbage collection? You have no idea.
**The Solution**: **Prometheus & Grafana**.

1.  **Install the Stack**: Use the `kube-prometheus-stack` Helm chart.
2.  **Expose Metrics**: Configure Keycloak (via env vars) to expose a `/metrics` endpoint.
3.  **Visualize**: Create a Grafana Dashboard visualizing Login Success/Failures per second.

*Result*: You have generic visibility into the health of your platform.

---

## Level 5: Policy Enforcement (Stop Mistakes)

**The Problem**: A developer deploys a pod that runs as `root`, pulls images from Docker Hub (instead of your internal registry), and has no resource limits.
**The Solution**: **Kyverno** (or OPA Gatekeeper).

1.  **Install Kyverno**: A policy engine for Kubernetes.
2.  **Write Policies**:
    *   *Rule 1*: "Require all images to start with `registry.kube-system.svc.cluster.local`"
    *   *Rule 2*: "Block any pod using `latest` tag."
3.  **Enforce**: Try to deploy a "bad" pod and watch the API Server reject it.

*Result*: You have automated governance and security guardrails.
