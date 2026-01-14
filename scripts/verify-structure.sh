#!/bin/bash

# Assignment Verification Script
# This script checks if all required files for the assignment are present

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=== MuchToDo Container Assessment - File Verification ===${NC}\n"

# Counter for checks
total_checks=0
passed_checks=0

# Function to check file existence
check_file() {
    local file=$1
    local description=$2
    total_checks=$((total_checks + 1))
    
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $description"
        passed_checks=$((passed_checks + 1))
    else
        echo -e "${RED}✗${NC} $description"
        echo -e "   ${RED}Missing: $file${NC}"
    fi
}

# Function to check directory existence
check_dir() {
    local dir=$1
    local description=$2
    total_checks=$((total_checks + 1))
    
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✓${NC} $description"
        passed_checks=$((passed_checks + 1))
    else
        echo -e "${RED}✗${NC} $description"
        echo -e "   ${RED}Missing: $dir${NC}"
    fi
}

echo -e "${YELLOW}Phase 1: Docker Setup${NC}"
check_file "Dockerfile" "Dockerfile"
check_file "docker-compose.yml" "Docker Compose configuration"
check_file ".dockerignore" ".dockerignore file"
echo ""

echo -e "${YELLOW}Phase 2: Kubernetes Manifests${NC}"
check_file "kubernetes/namespace.yaml" "Namespace configuration"
echo ""

echo -e "${YELLOW}MongoDB Resources${NC}"
check_file "kubernetes/mongodb/mongodb-secret.yaml" "MongoDB Secret"
check_file "kubernetes/mongodb/mongodb-configmap.yaml" "MongoDB ConfigMap"
check_file "kubernetes/mongodb/mongodb-pvc.yaml" "MongoDB PVC"
check_file "kubernetes/mongodb/mongodb-deployment.yaml" "MongoDB Deployment"
check_file "kubernetes/mongodb/mongodb-service.yaml" "MongoDB Service"
echo ""

echo -e "${YELLOW}Backend Resources${NC}"
check_file "kubernetes/backend/backend-secret.yaml" "Backend Secret"
check_file "kubernetes/backend/backend-configmap.yaml" "Backend ConfigMap"
check_file "kubernetes/backend/backend-deployment.yaml" "Backend Deployment"
check_file "kubernetes/backend/backend-service.yaml" "Backend Service"
check_file "kubernetes/backend/backend-sa.yaml" "Backend Service Account"
echo ""

echo -e "${YELLOW}Ingress${NC}"
check_file "kubernetes/ingress.yaml" "Ingress configuration"
echo ""

echo -e "${YELLOW}Phase 3: Automation Scripts${NC}"
check_file "scripts/docker-build.sh" "Docker build script"
check_file "scripts/docker-run.sh" "Docker run script"
check_file "scripts/k8s-deploy.sh" "Kubernetes deploy script"
check_file "scripts/k8s-cleanup.sh" "Kubernetes cleanup script"
echo ""

echo -e "${YELLOW}Phase 4: Documentation${NC}"
check_file "README.md" "Main README"
check_dir "evidence" "Evidence directory"
check_file "evidence/README.md" "Evidence README"
check_file "COMPLETION_SUMMARY.md" "Completion Summary"
echo ""

# Summary
echo -e "${YELLOW}=== Verification Summary ===${NC}"
echo -e "Total checks: $total_checks"
echo -e "Passed: ${GREEN}$passed_checks${NC}"
echo -e "Failed: ${RED}$((total_checks - passed_checks))${NC}"
echo ""

if [ $passed_checks -eq $total_checks ]; then
    echo -e "${GREEN}✓ All required files are present!${NC}"
    echo -e "${GREEN}✓ Assignment structure is complete!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some files are missing!${NC}"
    echo -e "${YELLOW}Please create the missing files before submission.${NC}"
    exit 1
fi
