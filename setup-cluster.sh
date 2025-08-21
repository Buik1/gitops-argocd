#!/bin/bash

echo "🚀 Setting up GitOps environment with ArgoCD..."

# Create Kind cluster
echo "📦 Creating Kind cluster..."
kind create cluster --name gitops-demo --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 8080
    protocol: TCP
  - containerPort: 443
    hostPort: 8443
    protocol: TCP
EOF

# Install ArgoCD
echo "🔧 Installing ArgoCD..."
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
echo "⏳ Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Get ArgoCD admin password
echo "🔑 Getting ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Port forward ArgoCD UI
echo "🌐 Starting ArgoCD UI port forward..."
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

echo "✅ Setup complete!"
echo "🔗 ArgoCD UI: https://localhost:8080"
echo "👤 Username: admin"
echo "🔐 Password: $ARGOCD_PASSWORD"
echo ""
echo "📋 Next steps:"
echo "1. Access ArgoCD UI at https://localhost:8080"
echo "2. Login with admin/$ARGOCD_PASSWORD"
echo "3. Create application from argocd-config/application.yaml"