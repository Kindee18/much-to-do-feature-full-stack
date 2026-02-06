# Quick Testing Guide for MuchToDo Container Assessment

This guide provides quick commands to test both Docker and Kubernetes deployments.

## Prerequisites Check

```bash
# Verify Docker is installed and running
docker --version
docker compose version

# Verify Kubernetes tools
kubectl version --client
kind version

# Verify scripts are executable
ls -lh scripts/
```

## Test 1: Docker Build

```bash
# Run the build script
./scripts/docker-build.sh

# Verify the image
docker images | grep muchtodo-backend
```

**Expected Result**: Image `muchtodo-backend:latest` should be listed with an optimized size.

## Test 2: Docker Compose Deployment

```bash
# Run the docker-compose stack
./scripts/docker-run.sh

# Wait for services to start
sleep 10

# Check running containers
docker ps --filter "name=muchtodo"

# Test the health endpoint
curl http://localhost:3000/health

# Expected response:
# {"cache":"disabled","database":"ok"}
```

## Test 3: Kubernetes Deployment with Kind

```bash
# Deploy to Kubernetes
./scripts/k8s-deploy.sh

# Wait for pods to be ready
kubectl get pods -n muchtodo-ns -w

# Verify all resources
kubectl get all -n muchtodo-ns
kubectl get ingress -n muchtodo-ns

# Test the application via Ingress (Port 80)
curl http://localhost/health

# Or via port-forward
kubectl port-forward svc/backend 3000:80 -n muchtodo-ns &
curl http://localhost:3000/health

# Check logs
kubectl logs -l app=backend -n muchtodo-ns
```

## Common Issues and Quick Fixes

### Issue: Port 3000 Already in Use
```bash
lsof -i :3000
kill -9 <PID>
```

### Issue: Image Not Loading into Kind
```bash
kind load docker-image muchtodo-backend:latest --name muchtodo-cluster
```

## Cleanup Commands

```bash
# Stop Docker Compose
docker-compose down

# Clean up Kubernetes and Kind cluster
./scripts/k8s-cleanup.sh
```

## Final Verification
```bash
# Run the structure verification script
./scripts/verify-structure.sh
```
