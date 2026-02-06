#!/bin/bash
set -e

CLUSTER_NAME="muchtodo-cluster"

echo "Checking if Kind cluster exists..."
if ! kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
    echo "Creating Kind cluster..."
    # Create cluster with ingress support
    cat <<EOF | kind create cluster --name "${CLUSTER_NAME}" --config=-
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
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF
else
    echo "Cluster '${CLUSTER_NAME}' already exists."
fi

echo "Loading Docker image into Kind..."
kind load docker-image muchtodo-backend:latest --name "${CLUSTER_NAME}"

echo "Applying Kubernetes manifests..."
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/mongodb/
kubectl apply -f kubernetes/backend/
kubectl apply -f kubernetes/ingress.yaml

echo "Installing Nginx Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "Deploy process complete. Wait for pods to be ready..."
kubectl get pods -n muchtodo-ns
