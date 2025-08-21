# Application Deployment Guide

## Project Structure
```
simple-app/
├── manifests/
│   └── deployment.yaml    # Kubernetes manifests
└── application.yaml       # ArgoCD application config
```

## Creating New Applications

### 1. Create Application Directory
```bash
mkdir my-new-app
mkdir my-new-app/manifests
```

### 2. Create Kubernetes Manifests
```yaml
# my-new-app/manifests/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
spec:
  selector:
    app: my-app
  ports:
  - port: 80
    targetPort: 80
```

### 3. Create ArgoCD Application
```yaml
# my-new-app/application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-username/gitops-argocd
    targetRevision: HEAD
    path: my-new-app/manifests
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### 4. Deploy to ArgoCD
```bash
kubectl apply -f my-new-app/application.yaml --validate=false
```

## Making Changes
1. Edit files in `manifests/` directory
2. Commit and push to Git
3. ArgoCD automatically syncs changes
4. Monitor in ArgoCD UI

## Common Commands
- View applications: `kubectl get applications -n argocd`
- Delete application: `kubectl delete -f application.yaml`
- Manual sync: Click "SYNC" in ArgoCD UI