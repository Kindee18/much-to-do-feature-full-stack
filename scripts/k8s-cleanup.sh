#!/bin/bash

# Kubernetes Cleanup Script for MuchToDo
# This script removes all MuchToDo resources from the Kind cluster and optionally deletes the cluster

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

echo -e "${YELLOW}[*] Starting Kubernetes cleanup process...${NC}"

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}[!] kubectl is not installed. Please install kubectl first.${NC}"
    exit 1
fi

# Check if Kind is installed
if ! command -v kind &> /dev/null; then
    echo -e "${RED}[!] Kind is not installed. Please install Kind first.${NC}"
    exit 1
fi

# Function to check if cluster exists
cluster_exists() {
    kind get clusters | grep -q "^${KIND_CLUSTER_NAME}$"
}

# Check if cluster exists
if ! cluster_exists; then
    echo -e "${YELLOW}[*] Kind cluster does not exist. Nothing to clean up.${NC}"
    exit 0
fi

# Set kubectl context
echo -e "${YELLOW}[*] Setting kubectl context to ${KIND_CLUSTER_NAME}...${NC}"
kubectl config use-context "kind-${KIND_CLUSTER_NAME}" 2>/dev/null || true

# Ask for confirmation
echo -e "${YELLOW}[!] WARNING: This will delete all resources in the much-todo namespace and optionally the Kind cluster.${NC}"
read -p "Continue with cleanup? (yes/no): " -r CONFIRM

if [[ ! $CONFIRM =~ ^[Yy][Ee][Ss]$ ]]; then
    echo -e "${YELLOW}[*] Cleanup cancelled.${NC}"
    exit 0
fi

# Delete Kubernetes namespace (this will delete all resources in it)
echo -e "${YELLOW}[*] Deleting namespace '${NAMESPACE}'...${NC}"
kubectl delete namespace "${NAMESPACE}" --ignore-not-found=true

# Wait for namespace to be deleted
echo -e "${YELLOW}[*] Waiting for namespace deletion...${NC}"
sleep 10

echo -e "${GREEN}[✓] Kubernetes resources deleted successfully!${NC}"

# Ask if user wants to delete the cluster
read -p "Do you want to delete the Kind cluster '${KIND_CLUSTER_NAME}'? (yes/no): " -r DELETE_CLUSTER

if [[ $DELETE_CLUSTER =~ ^[Yy][Ee][Ss]$ ]]; then
    echo -e "${YELLOW}[*] Deleting Kind cluster '${KIND_CLUSTER_NAME}'...${NC}"
    kind delete cluster --name "${KIND_CLUSTER_NAME}"
    
    echo -e "${GREEN}[✓] Kind cluster deleted successfully!${NC}"
    
    # Clean up kubectl context
    echo -e "${YELLOW}[*] Cleaning up kubectl context...${NC}"
    kubectl config delete-context "kind-${KIND_CLUSTER_NAME}" 2>/dev/null || true
else
    echo -e "${YELLOW}[*] Kind cluster '${KIND_CLUSTER_NAME}' will be kept for future use.${NC}"
fi

echo -e "${GREEN}[✓] Cleanup completed!${NC}"
echo -e "${YELLOW}[*] To deploy again, run: ./scripts/k8s-deploy.sh${NC}"
