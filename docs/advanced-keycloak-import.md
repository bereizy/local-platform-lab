# Advanced Iteration: Automating Keycloak Configuration

In the MVP phase, you likely configured Keycloak manually: creating a Realm, defining Users, and setting up OIDC Clients for your applications. 

However, as you move towards a production-ready mindset (and to save your sanity when restarting the lab), you should look at **"Configuration as Code"**. This allows you to define your Identity requirements in a file, which Keycloak loads automatically on startup.

## The Goal
Eliminate "ClickOps" (manual configuration in the UI) and ensure that every time Keycloak starts, it has your exact desired configuration state.

---

## Step 1: Export your Configuration
First, configure Keycloak manually in the UI exactly how you want it (Realm `lab-realm`, Clients, Users, etc.).

1.  Log into the Admin Console.
2.  Select your Realm (e.g., `lab-realm`).
3.  Go to **Realm Settings** > **Action** (top right) > **Partial Export**.
4.  Toggle **Include clients** and **Include groups/roles**.
5.  Save the file as `realm-export.json`.

*(Note: Users are not typically exported in "Partial Export". For a full export including users, you often need to use the CLI inside the container, but for this lab, just exporting the Realm/Client structure is usually a huge win).*

---

## Step 2: Create a Kubernetes Secret
Instead of baking this JSON file into the container image (which requires rebuilding the image), we will inject it using a Kubernetes Secret.

Run this command to turn your JSON file into a generic secret in the `platform` namespace:

```bash
kubectl create secret generic keycloak-realm-config \
  --from-file=realm-import.json=./realm-export.json \
  -n platform
```

*   `keycloak-realm-config`: The name of the secret object.
*   `realm-import.json`: The filename that will appear **inside** the container.
*   `./realm-export.json`: The path to your file on your local machine.

---

## Step 3: Update the Keycloak Manifest
Now, modify `manifests/platform/02-keycloak.yaml` to mount this secret. Keycloak looks for import files in `/opt/keycloak/data/import`.

**Update 1: Add the Command Arg**
Update the `args` to explicitly request an import.
*(Note: `start-dev` usually auto-imports, but being explicit is better).*

```yaml
        args: ["start-dev", "--import-realm"]
```

**Update 2: Mount the Volume**
Add the Volume Mount to the container and the Volume definition to the Pod spec.

```yaml
      containers:
      - name: keycloak
        # ... existing config ...
        volumeMounts:
        - name: realm-import
          mountPath: /opt/keycloak/data/import
          readOnly: true
      volumes:
      - name: realm-import
        secret:
          secretName: keycloak-realm-config
```

---

## Step 4: Validate
1.  Apply the changes:
    ```bash
    kubectl apply -f manifests/platform/02-keycloak.yaml
    ```
    *(This will restart the Keycloak pod)*.

2.  Watch the logs:
    ```bash
    kubectl logs -f -n platform deploy/keycloak
    ```

3.  Look for a line saying:
    `INFO  [org.keycloak.services] (ServerService Thread Pool -- 1) Imported realm [lab-realm] from file /opt/keycloak/data/import/realm-import.json`

## Why is this "Advanced"?
This pattern moves you away from treating servers as "Pets" (that you manually nurture and configure) to treating them as "Cattle" (replaceable, automated infrastructure). This is a core principle of cloud-native engineering.
