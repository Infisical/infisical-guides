# ESO Demo - External Secrets Operator with Infisical

A working demo that syncs secrets from [Infisical](https://infisical.com) into Kubernetes using the [External Secrets Operator](https://external-secrets.io) with [Kubernetes Auth](https://infisical.com/docs/documentation/platform/identities/kubernetes-auth) — no static credentials required.

## How It Works

```
Infisical (source of truth)
    |
    |  Kubernetes Auth (TokenReview)
    v
SecretStore --> ExternalSecret --> K8s Secret --> Pod (env vars)
```

1. A **[SecretStore](https://external-secrets.io/latest/provider/infisical/)** defines the connection to Infisical using [Kubernetes Auth](https://infisical.com/docs/documentation/platform/identities/kubernetes-auth)
2. An **[ExternalSecret](https://external-secrets.io/latest/api/externalsecret/)** maps specific Infisical secrets to a Kubernetes Secret
3. ESO syncs the values on a configurable refresh interval
4. The app consumes the Kubernetes Secret as environment variables

The demo app is a simple Flask page that displays the synced secret values so you can see the pipeline working end to end.

## Project Structure

```
.
├── app.py                              # Flask app - reads env vars and displays them
├── templates/
│   └── index.html                      # Dark-themed UI showing secret values
├── Dockerfile                          # Container image (python:3.12-slim)
├── requirements.txt                    # Flask dependency
└── k8s/
    ├── rbac-setup.yaml                 # ServiceAccount + ClusterRoleBinding for token review
    ├── infisical-identity.yaml         # Machine Identity ID reference
    ├── secretstore.yaml                # ESO connection config (Infisical + Kubernetes Auth)
    ├── externalsecret.yaml             # Secret mappings (what to fetch from Infisical)
    ├── deployment.yaml                 # App deployment
    └── service.yaml                    # LoadBalancer service
```

## Prerequisites

- A Kubernetes cluster with a **public API server endpoint** (e.g. EKS, GKE, AKS)

> **Note:** Infisical Cloud needs to call back to your cluster's TokenReview API, so minikube and other local clusters won't work — use a cloud-hosted cluster instead.
- `kubectl`, `helm` installed
- Docker installed (to build the app image)
- An [Infisical](https://infisical.com) account
- A container registry (e.g. ECR, Docker Hub, GCR)

## Setup

### 1. Push the app image to your container registry

Build and push the image. Example using AWS ECR:

```bash
aws ecr create-repository --repository-name eso-demo
aws ecr get-login-password | docker login --username AWS --password-stdin <account-id>.dkr.ecr.<region>.amazonaws.com
docker build --platform linux/amd64 -t <account-id>.dkr.ecr.<region>.amazonaws.com/eso-demo:latest .
docker push <account-id>.dkr.ecr.<region>.amazonaws.com/eso-demo:latest
```

Update the `image` field in `k8s/deployment.yaml` to match your registry path.

### 2. Deploy the app

```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

At this point, the app is running but all secrets show `<not set>`.

### 3. Install External Secrets Operator

```bash
helm repo add external-secrets https://charts.external-secrets.io
helm repo update
helm install external-secrets external-secrets/external-secrets \
  --namespace external-secrets --create-namespace --set installCRDs=true
```

### 4. Set up RBAC for token review

Infisical needs to validate service account tokens via the Kubernetes TokenReview API:

```bash
kubectl apply -f k8s/rbac-setup.yaml
```

Retrieve the token reviewer JWT:

```bash
kubectl get secret infisical-token-reviewer-token -o=jsonpath='{.data.token}' | base64 --decode
```

Save this token — you'll need it when configuring Infisical.

### 5. Configure Infisical

1. [Create a project](https://infisical.com/docs/documentation/platform/secrets-mgmt/project) and add your secrets in the `dev` environment (e.g. `DB_HOST`, `DB_PORT`, `DB_USERNAME`, `DB_PASSWORD`, `API_KEY`)
2. Note your **project slug** from [Project Settings](https://infisical.com/docs/documentation/platform/project)
3. Create a [Machine Identity](https://infisical.com/docs/documentation/platform/identities/machine-identities) in your project (Access Control → Identities)
4. Create a [custom role](https://infisical.com/docs/documentation/platform/access-controls/role-based-access-controls) scoped to **read-only** access on secrets in the `dev` environment, and assign it to the identity
5. Add [Kubernetes Auth](https://infisical.com/docs/documentation/platform/identities/kubernetes-auth) to the identity:
   - **Kubernetes Host:** your cluster's API server URL (`kubectl cluster-info`)
   - **Token Reviewer JWT:** the token from step 4
   - **Allowed Service Account Names:** `external-secrets`
   - **Allowed Namespaces:** `external-secrets`
   - **CA Certificate:** *(optional)* not needed for cloud-hosted clusters (EKS, GKE, AKS). For self-hosted clusters, retrieve it with:
     ```bash
     kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 --decode
     ```
6. Copy the **Identity ID** from the Machine Identity page

> **Note:** The identity ID is not sensitive — it's a reference ID that is useless without the Kubernetes Auth flow behind it.

### 6. Update and apply the manifests

Update these files with your values:

- `k8s/infisical-identity.yaml` — replace the `identityId` with yours
- `k8s/secretstore.yaml` — update `projectSlug` to match your Infisical project
- `k8s/externalsecret.yaml` — update the `data` keys to match your Infisical secret names

> **Note:** ESO syncs are all-or-nothing. If any key in the ExternalSecret fails to fetch from Infisical, none of them sync. Make sure all keys exist in your Infisical project.

```bash
kubectl apply -f k8s/infisical-identity.yaml
kubectl apply -f k8s/secretstore.yaml
kubectl apply -f k8s/externalsecret.yaml
```

### 7. Verify and restart

```bash
kubectl get secretstore infisical-store        # Should show Ready: True
kubectl get externalsecret eso-demo-external    # Should show SecretSynced
kubectl rollout restart deployment eso-demo
kubectl get svc eso-demo
```

Open `http://<EXTERNAL-IP>:5000` — your secrets should now appear in green.

## Teardown

> **Note:** If you tear down your cluster and create a new one, you'll need to update the Kubernetes Auth settings in Infisical — each cluster has a different API server URL and token reviewer JWT.

Delete the cluster when you're done to avoid charges. Example for EKS:

```bash
eksctl delete cluster --name eso-demo --region us-east-1
```

## Learn More

- [Kubernetes Auth](https://infisical.com/docs/documentation/platform/identities/kubernetes-auth) — how Infisical authenticates Kubernetes workloads
- [Machine Identities](https://infisical.com/docs/documentation/platform/identities/machine-identities) — non-human identities for workloads and applications
- [Access Controls](https://infisical.com/docs/documentation/platform/access-controls/role-based-access-controls) — RBAC, custom roles, and attribute-based access controls
- [Infisical Kubernetes Operator](https://infisical.com/docs/integrations/platforms/kubernetes) — Infisical's native K8s operator (alternative to ESO)
- [ESO Infisical Provider](https://external-secrets.io/latest/provider/infisical/) — External Secrets Operator docs for the Infisical provider
- [Infisical Documentation](https://infisical.com/docs) — full platform docs

