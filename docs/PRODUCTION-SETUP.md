# Production Kubernetes Setup Guide

## What You Need for Full CI/CD Pipeline

Your GitHub Actions pipeline is **already configured** to run tests and push to Docker Hub. You just need to set up the production Kubernetes cluster and Harness.

---

## Current Pipeline Status ✅

**Already Working:**
- ✅ GitHub Actions workflow (`.github/workflows/static-site-tests-pipeline.yml`)
- ✅ Unit tests (Jest)
- ✅ Security scanning (Gitleaks, CodeQL)
- ✅ SonarCloud analysis
- ✅ Docker Scout vulnerability scanning
- ✅ Docker Hub integration (chrisbromatello/wedding-site)
- ✅ Helm chart for deployment (`wedding-site-chart/`)
- ✅ Harness webhook trigger

**Needs Setup:**
- ❌ Production Kubernetes cluster
- ❌ Harness configuration to receive webhook and deploy
- ❌ GitHub Secrets configuration

---

## Step 1: Choose & Set Up Production Kubernetes Cluster

**You CANNOT use Minikube for production** - it's local only. Choose one:

### Option A: Cloud Kubernetes (Recommended)

#### **AWS EKS (Elastic Kubernetes Service)**
```bash
# Install AWS CLI and eksctl
aws configure
eksctl create cluster --name wedding-site-prod --region us-east-1 --nodes 2
```

#### **Google GKE (Google Kubernetes Engine)**
```bash
# Install gcloud CLI
gcloud auth login
gcloud container clusters create wedding-site-prod --zone us-central1-a --num-nodes 2
```

#### **Azure AKS (Azure Kubernetes Service)**
```bash
# Install Azure CLI
az login
az aks create --resource-group myResourceGroup --name wedding-site-prod --node-count 2
```

### Option B: Managed Kubernetes Providers (Easier)
- **DigitalOcean Kubernetes** (cheapest, easiest)
- **Linode Kubernetes Engine**
- **Civo Kubernetes**

All provide simple web UI setup, starting at $10-20/month.

---

## Step 2: Install Helm on Production Cluster

```bash
# Get cluster credentials (example for each cloud)
# AWS:
aws eks update-kubeconfig --name wedding-site-prod --region us-east-1

# GCP:
gcloud container clusters get-credentials wedding-site-prod --zone us-central1-a

# Azure:
az aks get-credentials --resource-group myResourceGroup --name wedding-site-prod

# Verify connection
kubectl get nodes

# Helm should already be installed, verify:
helm version
```

---

## Step 3: Configure GitHub Secrets

Your pipeline needs these secrets. Go to GitHub repo → Settings → Secrets and variables → Actions:

### Required Secrets:

1. **DOCKERHUB_USERNAME** - Your Docker Hub username (chrisbromatello)
2. **DOCKERHUB_TOKEN** - Docker Hub access token
   - Create at: https://hub.docker.com/settings/security
3. **SONAR_TOKEN** - SonarCloud token
   - Get at: https://sonarcloud.io/account/security
4. **HARNESS_WEBHOOK_URL** - Harness webhook URL (Step 4)
5. **PUSHGATEWAY_URL** - Prometheus Pushgateway URL (optional, for metrics)

### Optional (if deploying directly from GitHub Actions):
6. **KUBE_CONFIG** - Base64 encoded kubeconfig file
   ```bash
   cat ~/.kube/config | base64 | pbcopy
   ```

---

## Step 4: Set Up Harness

### Option A: Use Harness (Recommended for your setup)

1. **Sign up for Harness** (free tier available)
   - https://app.harness.io/auth/#/signup

2. **Create New Project**
   - Name: Wedding Site

3. **Set Up Service**
   - Service Type: Kubernetes
   - Artifact Source: Docker Hub
   - Image: chrisbromatello/wedding-site

4. **Set Up Environment**
   - Name: Production
   - Infrastructure: Your K8s cluster
   - Add K8s cluster credentials

5. **Create Pipeline**
   - Trigger: Webhook
   - Stage: Deploy using Helm
   - Helm Chart: Upload your `wedding-site-chart/` folder
   - Values:
     ```yaml
     image:
       repository: chrisbromatello/wedding-site
       tag: latest
       pullPolicy: Always
     ```

6. **Get Webhook URL**
   - Pipeline → Triggers → Create Webhook Trigger
   - Copy the webhook URL
   - Add to GitHub Secrets as `HARNESS_WEBHOOK_URL`

### Option B: Deploy Directly from GitHub Actions (Simpler, No Harness)

Modify the workflow to deploy directly instead of triggering Harness:

1. Add to `.github/workflows/static-site-tests-pipeline.yml` (replace harness_deploy step):

```yaml
  deploy_to_k8s:
    needs: [smoke_test]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Set up kubectl
        uses: azure/setup-kubectl@v3
      
      - name: Configure kubectl
        run: |
          echo "${{ secrets.KUBE_CONFIG }}" | base64 -d > kubeconfig
          export KUBECONFIG=./kubeconfig
      
      - name: Install/Upgrade with Helm
        run: |
          helm upgrade --install wedding-site ./wedding-site-chart \
            --set image.repository=chrisbromatello/wedding-site \
            --set image.tag=${{ github.sha }} \
            --set image.pullPolicy=Always
```

2. Add your kubeconfig as a GitHub Secret:
```bash
cat ~/.kube/config | base64 | pbcopy
# Add as KUBE_CONFIG in GitHub Secrets
```

---

## Step 5: Update Helm Chart for Production

Your chart is configured for Minikube. Update `wedding-site-chart/values.yaml`:

```yaml
replicaCount: 2  # Run 2 pods for redundancy

image:
  repository: chrisbromatello/wedding-site
  tag: latest
  pullPolicy: Always  # Changed from Never

service:
  type: LoadBalancer  # Changed from NodePort for cloud
  port: 80
  targetPort: 5000
  # Remove nodePort line for LoadBalancer

monitoring:
  enabled: false  # Keep disabled unless you install Prometheus Operator
  releaseLabel: monitoring
```

---

## Step 6: Deploy to Production

### First Deployment (Manual)

```bash
# Get kubectl access to your cluster
kubectl get nodes

# Deploy with Helm
helm install wedding-site ./wedding-site-chart \
  --set image.repository=chrisbromatello/wedding-site \
  --set image.tag=latest \
  --set image.pullPolicy=Always

# Get the external IP (cloud providers)
kubectl get services wedding-site-svc

# Wait for EXTERNAL-IP to appear (may take 2-5 minutes)
# Access your site at: http://<EXTERNAL-IP>
```

### Subsequent Deployments

After setup, just push to GitHub:
```bash
git push origin main
```

**Automated Flow:**
1. ✅ GitHub Actions runs all tests
2. ✅ Builds & pushes Docker image with commit SHA tag
3. ✅ Triggers Harness (or deploys directly)
4. ✅ Harness/GitHub Actions updates Kubernetes with new image
5. ✅ Site auto-deploys with zero downtime

---

## Pipeline Test Points

Your pipeline tests at **every stage**:

1. **Pre-commit** - Code formatting, linting
2. **Security** - Gitleaks (secrets), CodeQL (vulnerabilities)
3. **Quality** - Jest unit tests (30 tests)
4. **SonarCloud** - Code quality analysis
5. **Docker Scout** - Container vulnerability scanning
6. **Smoke Test** - Actual HTTP request to running container
7. **Production** - Kubernetes health checks & readiness probes

---

## Cost Estimates

**Cheapest Production Setup:**
- DigitalOcean Kubernetes: $12/month (2 nodes)
- Docker Hub: Free (public images)
- GitHub Actions: Free (public repos)
- Harness: Free tier available
- **Total: ~$12-15/month**

**AWS/GCP/Azure:**
- ~$75-150/month for small K8s cluster
- Free tier may cover some usage

---

## Quick Start Recommendation

**Fastest path to production:**

1. ✅ You already have tests and Docker image working
2. Create DigitalOcean Kubernetes cluster (10 minutes via UI)
3. Get kubeconfig, add as GitHub Secret
4. Modify workflow to deploy directly (skip Harness for now)
5. Update `values.yaml` for production
6. Push to GitHub → automatic deployment

**Want me to help you set up any of these steps?**
