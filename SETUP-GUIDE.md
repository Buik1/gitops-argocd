# GitOps with ArgoCD - Step by Step Guide

## Prerequisites
- Docker Desktop installed
- Kind installed
- kubectl installed
- Git repository (GitHub/GitLab)

## Step 1: Create Kind Cluster
```bash
kind create cluster --name gitops-demo
```

## Step 2: Install ArgoCD
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml --validate=false
```

## Step 3: Wait for ArgoCD to be Ready
```bash
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
kubectl get pods -n argocd
```

## Step 4: Get Admin Password
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## Step 5: Access ArgoCD UI
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
- Open: https://localhost:8080
- Username: `admin`
- Password: (from step 4)

## Step 6: Deploy Application
```bash
kubectl apply -f simple-app/application.yaml --validate=false
```

## Step 7: Verify Deployment
- Check ArgoCD UI for application status
- Verify pods: `kubectl get pods`

## GitOps Workflow
1. Make changes to manifests in Git
2. Push to repository
3. ArgoCD automatically syncs changes
4. Monitor in ArgoCD UI

## Troubleshooting
- Certificate errors: Add `--validate=false`
- Time sync issues: Run `w32tm /resync`
- Pod issues: Check `kubectl describe pod <pod-name> -n argocd`