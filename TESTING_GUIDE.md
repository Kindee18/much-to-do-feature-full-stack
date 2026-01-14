# Quick Testing Guide for MuchToDo Container Assessment

This guide provides quick commands to test both Docker and Kubernetes deployments.

## Prerequisites Check

```bash
# Verify Docker is installed and running
docker --version
docker compose version  # or docker-compose --version

# Verify Kubernetes tools
kubectl version --client
kind version

# Verify scripts are executable
ls -lh scripts/
```

## Test 1: Docker Build

```bash
# Navigate to project root
cd /home/kindson/much-to-do-feature-full-stack

# Run the build script
./scripts/docker-build.sh

# Expected output:
# [✓] Docker image built successfully!
# [✓] Image: much-to-do:latest

# Verify the image
docker images | grep much-to-do
```

**Expected Result**: Image `much-to-do:latest` should be listed with size around 50-60MB.

## Test 2: Docker Compose Deployment

```bash
# Run the docker-compose stack
./scripts/docker-run.sh

# Wait for services to start (about 30 seconds)
sleep 30

# Check running containers
docker-compose -f Server/MuchToDo/docker-compose.yaml ps

# Expected: 2 containers running (mongodb, backend)

# Test the health endpoint
curl http://localhost:8080/health

# Expected response:
# {"database":"ok","cache":"ok"} or similar

# Check backend logs
docker-compose -f Server/MuchToDo/docker-compose.yaml logs backend

# Stop the stack
docker-compose -f Server/MuchToDo/docker-compose.yaml down
```

**Screenshot Checklist**:

- [ ] Docker build completion output
- [ ] `docker images` showing much-to-do:latest
- [ ] `docker-compose ps` showing running containers
- [ ] Health check curl response

## Test 3: Kubernetes Deployment with Kind

```bash
# Deploy to Kubernetes
./scripts/k8s-deploy.sh

# This will:
# 1. Create Kind cluster (if needed)
# 2. Build and load Docker image
# 3. Deploy all Kubernetes resources
# 4. Verify deployments

# Wait for pods to be ready (about 2 minutes)
watch kubectl get pods -n muchtodo

# Press Ctrl+C when all pods show "Running" status

# Verify deployments
kubectl get all -n muchtodo

# Check pod details
kubectl get pods -n muchtodo -o wide

# Check services
kubectl get svc -n muchtodo

# Check ingress
kubectl get ingress -n muchtodo

# Test the application via NodePort
curl http://localhost:30080/health

# Or via port-forward
kubectl port-forward -n muchtodo svc/backend-service 8080:8080 &
curl http://localhost:8080/health

# Check logs
kubectl logs -n muchtodo -l app=backend --tail=50

# Clean up (optional, for testing)
# ./scripts/k8s-cleanup.sh
```

**Screenshot Checklist**:

- [ ] Kind cluster creation (`kind get clusters`)
- [ ] Pods running (`kubectl get pods -n muchtodo`)
- [ ] Services created (`kubectl get svc -n muchtodo`)
- [ ] Deployments status (`kubectl get deployments -n muchtodo`)
- [ ] Application responding (`curl http://localhost:30080/health`)
- [ ] Pod logs showing successful startup

## Test 4: Kubernetes Resource Inspection

```bash
# Check namespace
kubectl get namespace muchtodo

# Check persistent volumes
kubectl get pvc -n muchtodo

# Check configmaps
kubectl get configmaps -n muchtodo

# Check secrets
kubectl get secrets -n muchtodo

# Describe backend deployment
kubectl describe deployment backend -n muchtodo

# Describe MongoDB deployment
kubectl describe deployment mongodb -n muchtodo

# Check events
kubectl get events -n muchtodo --sort-by='.lastTimestamp'
```

## Test 5: Application Functionality Testing

```bash
# Test health endpoint
curl http://localhost:30080/health

# Test Swagger documentation (if available)
curl http://localhost:30080/swagger/index.html

# Test API endpoints (example)
# Register a user
curl -X POST http://localhost:30080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "TestPassword123!"
  }'

# Login
curl -X POST http://localhost:30080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "TestPassword123!"
  }'
```

## Common Issues and Quick Fixes

### Issue: Port Already in Use

```bash
# Find process using port 8080
lsof -i :8080

# Kill the process
kill -9 <PID>

# Or use a different port in docker-compose.yml
```

### Issue: Docker Image Not Loading into Kind

```bash
# Manually load image
docker build -t much-to-do:latest .
kind load docker-image much-to-do:latest --name much-todo-cluster

# Verify
docker exec -it much-todo-cluster-control-plane crictl images | grep much-to-do
```

### Issue: Pods Not Starting

```bash
# Check pod events
kubectl describe pod <pod-name> -n muchtodo

# Check logs
kubectl logs <pod-name> -n muchtodo

# Restart deployment
kubectl rollout restart deployment/backend -n muchtodo
```

### Issue: MongoDB Connection Failed

```bash
# Check MongoDB pod
kubectl get pod -l app=mongodb -n muchtodo

# Check MongoDB logs
kubectl logs -l app=mongodb -n muchtodo

# Check service
kubectl get svc mongodb-service -n muchtodo

# Test connection from backend pod
kubectl exec -it <backend-pod> -n muchtodo -- sh
# Inside pod: wget -O- http://mongodb-service:27017
```

## Cleanup Commands

```bash
# Stop Docker Compose
cd Server/MuchToDo
docker-compose down -v

# Clean up Kubernetes (keeps cluster)
kubectl delete namespace muchtodo

# OR use cleanup script (deletes cluster)
cd /home/kindson/much-to-do-feature-full-stack
./scripts/k8s-cleanup.sh

# Remove Docker images
docker rmi much-to-do:latest
```

## Evidence Collection Commands

Run these commands and capture screenshots:

```bash
# 1. Docker build
./scripts/docker-build.sh
docker images | grep much-to-do

# 2. Docker Compose
docker-compose ps
curl http://localhost:8080/health

# 3. Kind cluster
kind get clusters
kubectl cluster-info

# 4. Kubernetes resources
kubectl get all -n muchtodo
kubectl get pods -n muchtodo -o wide
kubectl get svc -n muchtodo
kubectl get ingress -n muchtodo

# 5. Application access
curl http://localhost:30080/health
kubectl logs -n muchtodo -l app=backend --tail=20

# 6. Resource details
kubectl describe deployment backend -n muchtodo
kubectl top pods -n muchtodo
```

## Verification Checklist

- [ ] All scripts are executable (`chmod +x scripts/*.sh`)
- [ ] Docker image builds successfully
- [ ] Docker Compose stack starts without errors
- [ ] Application responds on http://localhost:8080
- [ ] Kind cluster creates successfully
- [ ] All Kubernetes manifests apply without errors
- [ ] All pods reach "Running" status
- [ ] Backend has 2 replicas running
- [ ] MongoDB has 1 replica running
- [ ] Application responds on http://localhost:30080
- [ ] Health check returns successful response
- [ ] All evidence screenshots captured

## Quick Verification Script

```bash
# Run the verification script
./scripts/verify-structure.sh

# Expected output:
# ✓ All required files are present!
# ✓ Assignment structure is complete!
```

## Summary

After completing all tests:

1. ✅ Docker image builds successfully
2. ✅ Docker Compose deployment works
3. ✅ Kubernetes deployment succeeds
4. ✅ Application is accessible and responds
5. ✅ All evidence screenshots captured
6. ✅ Ready for submission

---

**Last Updated**: January 14, 2026  
**Status**: Ready for Testing
