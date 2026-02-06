# Evidence Collection Commands

This document lists the commands used to build, deploy, and verify the MuchTodo application in the Linux environment.

## 1. Docker Build Evidence

```bash
# Build the optimized multi-stage Docker image
./scripts/docker-build.sh

# Verify the image exists
docker images muchtodo-backend
```

## 2. Docker Compose Evidence

```bash
# Run the application locally with MongoDB
./scripts/docker-run.sh

# Check running containers
docker ps --filter "name=muchtodo"

# Verify health check
curl -i http://localhost:3000/health
```

## 3. Kubernetes Deployment Commands

### Create Kind Cluster
```bash
# Create cluster with ingress support
./scripts/k8s-deploy.sh
```

### Manual Deployment Steps (Reference)
```bash
# Deploy Namespace
kubectl apply -f kubernetes/namespace.yaml

# Deploy MongoDB
kubectl apply -f kubernetes/mongodb/

# Deploy Backend
kubectl apply -f kubernetes/backend/

# Deploy Ingress
kubectl apply -f kubernetes/ingress.yaml
```

## 4. Verification Commands

### Check Pods
```bash
kubectl get pods -n muchtodo-ns
```

### Check Services
```bash
kubectl get svc -n muchtodo-ns
```

### Check Deployments
```bash
kubectl get deployments -n muchtodo-ns
```

### Check Ingress
```bash
kubectl get ingress -n muchtodo-ns
```

### View Logs
```bash
# Backend logs
kubectl logs -l app=backend -n muchtodo-ns

# MongoDB logs
kubectl logs -l app=mongodb -n muchtodo-ns
```

### Test Application Accessibility
```bash
# Via Ingress (direct host access)
curl -i http://localhost/health

# Via Port Forward (alternative)
kubectl port-forward svc/backend 3000:80 -n muchtodo-ns
curl -i http://localhost:3000/health
```

## 5. Metadata and Context
```bash
# Check current context
kubectl config current-context

# Check cluster info
kubectl cluster-info
```

## 6. Cleanup Commands
```bash
# Use the cleanup script
./scripts/k8s-cleanup.sh
```
