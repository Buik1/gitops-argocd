# Complete GitOps with ArgoCD Guide

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [ArgoCD Installation](#argocd-installation)
4. [Application Deployment](#application-deployment)
5. [GitOps Workflow](#gitops-workflow)
6. [ArgoCD UI Guide](#argocd-ui-guide)
7. [Troubleshooting](#troubleshooting)

## Prerequisites
- Docker Desktop installed and running
- Kind CLI installed
- kubectl CLI installed
- Git installed
- GitHub account

## Initial Setup

### 1. Create Kind Cluster
```bash
kind create cluster --name gitops-demo
```

### 2. Verify Cluster
```bash
kubectl cluster-info
kubectl get nodes
```

## ArgoCD Installation

### 1. Create ArgoCD Namespace
```bash
kubectl create namespace argocd
```

### 2. Install ArgoCD
```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml --validate=false
```

### 3. Wait for Pods to be Ready
```bash
kubectl get pods -n argocd
# Wait until all pods show 1/1 READY
```

### 4. Get Admin Password
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```
**Save this password!**

### 5. Access ArgoCD UI
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
- Open: https://localhost:8080
- Username: `admin`
- Password: (from step 4)
- Click "Advanced" → "Proceed to localhost" for certificate warning

## Application Deployment

### 1. Create GitHub Repository
1. Go to GitHub.com
2. Create new repository: `gitops-argocd`
3. Make it public
4. Don't initialize with README

### 2. Push Code to GitHub
```bash
git init
git add .
git commit -m "Initial GitOps setup"
git remote add origin https://github.com/YOUR-USERNAME/gitops-argocd.git
git push -u origin master
```

### 3. Update Application Configuration
Edit `simple-app/application.yaml`:
```yaml
spec:
  source:
    repoURL: https://github.com/YOUR-USERNAME/gitops-argocd.git
```

### 4. Deploy Application to ArgoCD
```bash
kubectl apply -f simple-app/application.yaml --validate=false
```

### 5. Verify Deployment
```bash
kubectl get applications -n argocd
kubectl get pods
```

## GitOps Workflow

### Making Changes
1. **Edit manifests** in `simple-app/manifests/deployment.yaml`
2. **Commit changes**:
   ```bash
   git add .
   git commit -m "Update application"
   git push origin master
   ```
3. **ArgoCD automatically syncs** (within 3 minutes)
4. **Verify changes**:
   ```bash
   kubectl get pods
   ```

### Example Change - Scale Application
```bash
# Edit deployment.yaml: change replicas: 2 to replicas: 3
git add .
git commit -m "Scale to 3 replicas"
git push origin master
```

## ArgoCD UI Guide

### Main Dashboard
- Shows all applications
- Status indicators: Synced/OutOfSync, Healthy/Degraded
- Click application name to view details

### Application Details View
- **Tree View**: Shows all Kubernetes resources
- **SYNC Button**: Manually trigger sync
- **REFRESH Button**: Check Git for changes
- **APP DETAILS**: View configuration

### Status Meanings
- **✅ Synced**: Git matches cluster state
- **🔄 OutOfSync**: Changes detected in Git
- **❤️ Healthy**: All resources running properly
- **⚠️ Degraded**: Some resources have issues

### Manual Operations
- **Sync**: Apply Git changes to cluster
- **Refresh**: Check Git for new commits
- **Hard Refresh**: Force refresh from Git
- **Delete**: Remove application

## Troubleshooting

### Common Issues

#### Certificate Errors
```bash
# Add --validate=false to kubectl commands
kubectl apply -f file.yaml --validate=false
```

#### Time Sync Issues
```bash
w32tm /resync
```

#### ArgoCD Pods Not Starting
```bash
kubectl get pods -n argocd
kubectl describe pod <pod-name> -n argocd
kubectl logs <pod-name> -n argocd
```

#### Application Not Syncing
1. Check repository URL is correct
2. Verify repository is public
3. Check path in application.yaml
4. Manual refresh in UI

#### Repository Not Found
- Ensure GitHub repository exists
- Verify repository is public
- Check URL spelling in application.yaml

### Useful Commands
```bash
# Check application status
kubectl get applications -n argocd

# View application details
kubectl describe application simple-app -n argocd

# Check ArgoCD server logs
kubectl logs -n argocd deployment/argocd-server

# Restart ArgoCD server
kubectl rollout restart deployment/argocd-server -n argocd

# Delete and recreate application
kubectl delete -f simple-app/application.yaml
kubectl apply -f simple-app/application.yaml --validate=false
```

## Next Steps
1. Create multiple applications
2. Set up CI/CD pipeline
3. Implement multi-environment deployments
4. Add monitoring and alerting
5. Configure RBAC and security policies

## Project Structure
```
gitops-argocd/
├── simple-app/
│   ├── manifests/
│   │   └── deployment.yaml
│   └── application.yaml
├── docs/
├── SETUP-GUIDE.md
├── APPLICATION-GUIDE.md
└── COMPLETE-GUIDE.md
```