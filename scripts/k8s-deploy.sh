#!/bin/bash

# Kubernetes Deploy Script for MuchToDo
# This script deploys the entire application to a Kind cluster

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
KIND_CLUSTER_NAME="much-todo-cluster"
NAMESPACE="much-todo"
KUBERNETES_DIR="./kubernetes"
IMAGE_NAME="much-to-do"
IMAGE_TAG="latest"
REGISTRY="local"

echo -e "${YELLOW}[*] Starting Kubernetes deployment process...${NC}"

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}[!] kubectl is not installed. Please install kubectl first.${NC}"
    exit 1
fi

# Check if Kind is installed
if ! command -v kind &> /dev/null; then
    echo -e "${RED}[!] Kind is not installed. Please install Kind first.${NC}"
    echo -e "${YELLOW}[*] You can install Kind from: https://kind.sigs.k8s.io/docs/user/quick-start/${NC}"
    exit 1
fi

# Function to check if Kind cluster exists
cluster_exists() {
    kind get clusters | grep -q "^${KIND_CLUSTER_NAME}$"
}

# Function to create Kind cluster
create_kind_cluster() {
    echo -e "${YELLOW}[*] Creating Kind cluster: ${KIND_CLUSTER_NAME}${NC}"
    
    kind create cluster --name "${KIND_CLUSTER_NAME}" --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30080
    hostPort: 8080
    listenAddress: "127.0.0.1"
    protocol: tcp
EOF
    
    echo -e "${GREEN}[✓] Kind cluster created successfully!${NC}"
}

# Function to load Docker image into Kind
load_docker_image() {
    echo -e "${YELLOW}[*] Loading Docker image into Kind cluster...${NC}"
    
    # Build image if it doesn't exist
    if ! docker images | grep -q "${IMAGE_NAME}:${IMAGE_TAG}"; then
        echo -e "${YELLOW}[*] Docker image not found. Building...${NC}"
        ./scripts/docker-build.sh
    fi
    
    kind load docker-image "${IMAGE_NAME}:${IMAGE_TAG}" --name "${KIND_CLUSTER_NAME}"
    echo -e "${GREEN}[✓] Docker image loaded into Kind cluster!${NC}"
}

# Function to deploy to Kubernetes
deploy_to_k8s() {
    echo -e "${YELLOW}[*] Deploying to Kubernetes...${NC}"
    
    # Check if kubernetes directory exists
    if [ ! -d "$KUBERNETES_DIR" ]; then
        echo -e "${RED}[!] Kubernetes manifests directory not found at $KUBERNETES_DIR${NC}"
        exit 1
    fi
    
    # Set kubectl context
    kubectl cluster-info --context "kind-${KIND_CLUSTER_NAME}"
    kubectl config use-context "kind-${KIND_CLUSTER_NAME}"
    
    # Create namespace
    echo -e "${YELLOW}[*] Creating namespace...${NC}"
    kubectl apply -f "${KUBERNETES_DIR}/namespace.yaml"
    
    # Deploy MongoDB
    echo -e "${YELLOW}[*] Deploying MongoDB...${NC}"
    kubectl apply -f "${KUBERNETES_DIR}/mongodb/mongodb-secret.yaml"
    kubectl apply -f "${KUBERNETES_DIR}/mongodb/mongodb-configmap.yaml"
    kubectl apply -f "${KUBERNETES_DIR}/mongodb/mongodb-pvc.yaml"
    kubectl apply -f "${KUBERNETES_DIR}/mongodb/mongodb-deployment.yaml"
    kubectl apply -f "${KUBERNETES_DIR}/mongodb/mongodb-service.yaml"
    
    # Wait for MongoDB to be ready
    echo -e "${YELLOW}[*] Waiting for MongoDB to be ready...${NC}"
    kubectl wait --for=condition=ready pod -l app=mongodb -n "$NAMESPACE" --timeout=300s
    
    # Deploy Backend
    echo -e "${YELLOW}[*] Deploying Backend API...${NC}"
    kubectl apply -f "${KUBERNETES_DIR}/backend/backend-secret.yaml"
    kubectl apply -f "${KUBERNETES_DIR}/backend/backend-configmap.yaml"
    kubectl apply -f "${KUBERNETES_DIR}/backend/backend-sa.yaml"
    kubectl apply -f "${KUBERNETES_DIR}/backend/backend-deployment.yaml"
    kubectl apply -f "${KUBERNETES_DIR}/backend/backend-service.yaml"
    
    # Wait for Backend to be ready
    echo -e "${YELLOW}[*] Waiting for Backend API to be ready...${NC}"
    kubectl wait --for=condition=ready pod -l app=backend -n "$NAMESPACE" --timeout=300s
    
    # Deploy Ingress
    echo -e "${YELLOW}[*] Deploying Ingress...${NC}"
    kubectl apply -f "${KUBERNETES_DIR}/ingress.yaml"
    
    echo -e "${GREEN}[✓] Kubernetes deployment completed!${NC}"
}

# Main deployment flow
echo -e "${BLUE}[*] ===== Kubernetes Deployment Summary =====${NC}"
echo -e "${BLUE}[*] Cluster Name: ${KIND_CLUSTER_NAME}${NC}"
echo -e "${BLUE}[*] Namespace: ${NAMESPACE}${NC}"
echo -e "${BLUE}[*] Image: ${IMAGE_NAME}:${IMAGE_TAG}${NC}"
echo ""

# Check if cluster exists
if cluster_exists; then
    echo -e "${YELLOW}[*] Kind cluster already exists. Proceeding with deployment...${NC}"
else
    echo -e "${YELLOW}[*] Kind cluster does not exist. Creating...${NC}"
    create_kind_cluster
fi

# Load Docker image
load_docker_image

# Deploy to Kubernetes
deploy_to_k8s

# Show deployment status
echo -e "${YELLOW}[*] Checking deployment status...${NC}"
echo ""
echo -e "${BLUE}[*] Pods in namespace '${NAMESPACE}':${NC}"
kubectl get pods -n "$NAMESPACE" -o wide
echo ""
echo -e "${BLUE}[*] Services in namespace '${NAMESPACE}':${NC}"
kubectl get svc -n "$NAMESPACE"
echo ""
echo -e "${BLUE}[*] Deployments in namespace '${NAMESPACE}':${NC}"
kubectl get deployments -n "$NAMESPACE"
echo ""

# Print access information
echo -e "${GREEN}[✓] Deployment completed successfully!${NC}"
echo ""
echo -e "${YELLOW}[*] Access your application:${NC}"
echo -e "    - Backend API (NodePort): http://localhost:8080"
echo -e "    - Check service status: kubectl get svc -n ${NAMESPACE}"
echo ""
echo -e "${YELLOW}[*] Useful kubectl commands:${NC}"
echo -e "    - View logs: kubectl logs -f deployment/backend -n ${NAMESPACE}"
echo -e "    - Describe pod: kubectl describe pod <pod-name> -n ${NAMESPACE}"
echo -e "    - Port forward: kubectl port-forward -n ${NAMESPACE} svc/backend 8080:8080"
echo -e "    - Exec into pod: kubectl exec -it <pod-name> -n ${NAMESPACE} -- /bin/sh"
echo ""
echo -e "${YELLOW}[*] To clean up, run:${NC}"
echo -e "    ./scripts/k8s-cleanup.sh"
