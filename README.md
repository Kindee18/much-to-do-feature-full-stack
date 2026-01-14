# MuchToDo - Container Assessment & Kubernetes Deployment

Complete containerization and Kubernetes deployment solution for the MuchToDo backend application.

## 📋 Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Phase 1: Docker Setup](#phase-1-docker-setup)
- [Phase 2: Kubernetes Deployment](#phase-2-kubernetes-deployment)
- [Troubleshooting](#troubleshooting)
- [Additional Resources](#additional-resources)

## 🎯 Overview

This project containerizes the MuchToDo Golang backend application and provides:

- **Optimized Dockerfile** with multi-stage build for minimal image size
- **Docker Compose** setup for local development with MongoDB and Redis
- **Kubernetes manifests** for production-grade deployment
- **Kind cluster** configuration for local Kubernetes testing
- **Automation scripts** for easy build, deploy, and cleanup

### Technology Stack

- **Backend**: Go 1.25 with Gin framework
- **Database**: MongoDB 8.0 with replica set support
- **Cache**: Redis 7.2 for performance optimization
- **Container Runtime**: Docker & Docker Compose
- **Orchestration**: Kubernetes with Kind for local development
- **Ingress**: NGINX Ingress Controller (optional for Kind)

## 📁 Project Structure

```
container-assessment/
├── Dockerfile                          # Multi-stage build for Go backend
├── .dockerignore                       # Docker build context exclusions
├── .env.example                        # Environment variables template
├── docker-compose.yaml                 # Local development stack (in Server/MuchToDo)
├── kubernetes/
│   ├── namespace.yaml                  # Kubernetes namespace definition
│   ├── mongodb/
│   │   ├── mongodb-secret.yaml         # MongoDB credentials
│   │   ├── mongodb-configmap.yaml      # MongoDB configuration
│   │   ├── mongodb-pvc.yaml            # Persistent volume for data
│   │   ├── mongodb-deployment.yaml     # MongoDB deployment
│   │   └── mongodb-service.yaml        # MongoDB service
│   ├── backend/
│   │   ├── backend-secret.yaml         # Backend sensitive config
│   │   ├── backend-configmap.yaml      # Backend environment config
│   │   ├── backend-deployment.yaml     # Backend API deployment (2 replicas)
│   │   ├── backend-service.yaml        # Backend service (NodePort)
│   │   └── backend-sa.yaml             # Service account for RBAC
│   └── ingress.yaml                    # Ingress for external access
├── scripts/
│   ├── docker-build.sh                 # Build Docker image
│   ├── docker-run.sh                   # Run Docker Compose stack
│   ├── k8s-deploy.sh                   # Deploy to Kind cluster
│   └── k8s-cleanup.sh                  # Cleanup Kind cluster
├── README.md                           # This file
└── evidence/
    └── [screenshots of successful deployment]
```

## 📋 Prerequisites

### For Docker Development

1. **Docker Desktop** (includes Docker and Docker Compose)

   - Download from: https://www.docker.com/products/docker-desktop
   - Verify installation: `docker --version && docker-compose --version`

2. **Make** (optional, for running Makefile commands)
   - On Windows: Install via Chocolatey: `choco install make`

### For Kubernetes Deployment

1. All Docker prerequisites
2. **Kind** - Kubernetes in Docker

   - Installation: https://kind.sigs.k8s.io/docs/user/quick-start/
   - Verify: `kind version`

3. **kubectl** - Kubernetes command-line tool
   - Installation: https://kubernetes.io/docs/tasks/tools/
   - Verify: `kubectl version --client`

### Development Environment

- **Git** for version control
- **Bash** or compatible shell (for running scripts)
- Text editor or IDE (VSCode recommended)

## 🐳 Phase 1: Docker Setup

### Step 1: Prepare Environment

```bash
# Navigate to project root
cd much-to-do-feature-full-stack

# Copy environment template
cp .env.example .env

# Edit .env with your configuration
# At minimum, change JWT_SECRET_KEY to a strong random value
```

### Step 2: Build Docker Image

```bash
# Make scripts executable (on Linux/macOS)
chmod +x scripts/*.sh

# Build the Docker image
./scripts/docker-build.sh

# Or manually:
docker build -t much-to-do:latest -f Dockerfile .
```

**Expected Output**:

```
[*] Starting Docker build process...
[*] Building Docker image: much-to-do:latest
[✓] Docker image built successfully!
[✓] Image: much-to-do:latest
REPOSITORY    TAG       IMAGE ID       CREATED         SIZE
much-to-do    latest    abc123def456   2 seconds ago    85MB
```

### Step 3: Run Docker Compose Stack

```bash
# Navigate to Server/MuchToDo directory
cd Server/MuchToDo

# Run the stack
../../scripts/docker-run.sh

# Or manually:
docker-compose -f docker-compose.yaml up -d --build
```

**Services Available**:

- **Backend API**: http://localhost:8080
- **MongoDB**: mongodb:27017 (username: muchtodousr, password: Password!234)
- **Mongo Express**: http://localhost:8081 (username: admin, password: admin123)
- **Redis**: localhost:6379
- **Redis Commander**: http://localhost:8082

### Step 4: Verify Docker Compose Deployment

```bash
# Check running containers
docker-compose ps

# View application logs
docker-compose logs backend

# Test health endpoint
curl http://localhost:8080/health

# Expected response:
# {"database":"ok","cache":"ok"}

# Stop the stack
docker-compose down

# Clean up volumes (careful: deletes data)
docker-compose down -v
```

## ☸️ Phase 2: Kubernetes Deployment

### Step 1: Create Kind Cluster

The `k8s-deploy.sh` script handles cluster creation automatically. However, you can create it manually:

```bash
# Create Kind cluster with specific configuration
kind create cluster --name much-todo-cluster

# Or with custom config for port mapping:
kind create cluster --name much-todo-cluster --config - <<EOF
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

# Verify cluster
kind get clusters
kubectl cluster-info
```

### Step 2: Deploy to Kubernetes

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Deploy complete stack
./scripts/k8s-deploy.sh
```

This script will:

1. Create Kind cluster (if not exists)
2. Build and load Docker image
3. Create `much-todo` namespace
4. Deploy MongoDB with persistent storage
5. Deploy Backend API with 2 replicas
6. Create services and ingress

### Step 3: Verify Kubernetes Deployment

```bash
# Check namespace
kubectl get namespaces

# Check pods
kubectl get pods -n much-todo

# Check services
kubectl get svc -n much-todo

# Check deployments
kubectl get deployments -n much-todo

# View detailed pod information
kubectl describe pod <pod-name> -n much-todo

# Check pod logs
kubectl logs <pod-name> -n much-todo

# Expected output (pods should be in Running state):
# NAME                        READY   STATUS    RESTARTS   AGE
# mongodb-7c8f4b9c6d-2k3l4    1/1     Running   0          2m
# backend-5d6e7f8g9h-0k1l2    1/1     Running   0          1m
# backend-5d6e7f8g9h-3m4n5    1/1     Running   0          1m
```

### Step 4: Access the Application

```bash
# Via NodePort (direct access to port 8080)
curl http://localhost:8080/health

# Via port-forward
kubectl port-forward -n much-todo svc/backend 8080:8080 &
curl http://localhost:8080/health

# Via ingress (requires NGINX ingress controller)
# First, install ingress controller:
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/kind/deploy.yaml
```

### Step 5: Cleanup

```bash
# Delete all resources (keeps cluster)
kubectl delete namespace much-todo

# OR use cleanup script (with confirmation)
./scripts/k8s-cleanup.sh
```

## 🔧 Troubleshooting

### Docker Issues

#### "Docker daemon is not running"

```bash
# Start Docker Desktop (macOS/Windows)
open /Applications/Docker.app

# Or check if Docker service is running (Linux)
sudo systemctl start docker
```

#### "Cannot connect to database"

```bash
# Check MongoDB container
docker logs mongodb

# Verify network connectivity
docker network inspect much-todo_backend

# Restart services
docker-compose restart
```

#### "Health check failing"

```bash
# Test API directly
docker exec much-to-do-api curl -s http://localhost:8080/health

# Check logs
docker logs much-to-do-api
```

### Kubernetes Issues

#### "Pods not starting"

```bash
# Get pod status
kubectl describe pod <pod-name> -n much-todo

# Check events
kubectl get events -n much-todo

# Check logs
kubectl logs <pod-name> -n much-todo
```

#### "Image not found in cluster"

```bash
# Verify image is loaded in Kind
docker images | grep much-to-do
kind load docker-image much-to-do:latest --name much-todo-cluster

# Verify image in cluster
kubectl get nodes -n much-todo
```

#### "Cannot connect to MongoDB"

```bash
# Check MongoDB pod
kubectl describe pod -l app=mongodb -n much-todo

# Check MongoDB service
kubectl get svc mongodb -n much-todo

# Test connectivity
kubectl exec -it <backend-pod> -n much-todo -- /bin/sh
# Inside pod: mongosh mongodb://muchtodousr:Password!234@mongodb:27017/?authSource=admin
```

#### "Port 8080 already in use"

```bash
# Find process using port
lsof -i :8080

# Kill process or change port in kind-config.yaml and redeploy
kind delete cluster --name much-todo-cluster
# Edit cluster config and redeploy
```

## 📊 Monitoring and Management

### View Logs

```bash
# Docker Compose
docker-compose logs -f backend
docker-compose logs -f mongodb

# Kubernetes
kubectl logs -f deployment/backend -n much-todo
kubectl logs -f deployment/mongodb -n much-todo

# Specific pod
kubectl logs <pod-name> -n much-todo
```

### Access Services

```bash
# Port forwarding to access services locally
kubectl port-forward -n much-todo svc/backend 8080:8080
kubectl port-forward -n much-todo svc/mongodb 27017:27017

# Then access via:
# curl http://localhost:8080/health
# mongosh mongodb://localhost:27017
```

### Database Management

```bash
# Access MongoDB via Mongo Express (Docker)
http://localhost:8081

# Via mongosh in Kubernetes
kubectl exec -it <mongodb-pod> -n much-todo -- mongosh -u muchtodousr -p Password!234 --authenticationDatabase admin
```

### Resource Usage

```bash
# Check resource usage
kubectl top nodes
kubectl top pods -n much-todo

# Check resource limits
kubectl describe deployment backend -n much-todo
```

## 🔒 Security Considerations

### For Production Deployment

1. **Change Default Credentials**

   - Update JWT_SECRET_KEY in backend-secret.yaml
   - Update MONGO_INITDB_ROOT_PASSWORD in mongodb-secret.yaml
   - Use strong random passwords

2. **Use Private Container Registry**

   - Store images in private registry (ECR, GCR, ACR)
   - Update image references in deployment manifests

3. **Configure TLS/SSL**

   - Install cert-manager for automatic certificates
   - Update ingress with TLS configuration
   - Enable SECURE_COOKIE in production

4. **Network Policies**

   - Implement NetworkPolicy manifests
   - Restrict traffic between namespaces
   - Use service mesh (Istio) for advanced traffic management

5. **RBAC**

   - Service account already configured with basic setup
   - Create roles and rolebindings as needed
   - Principle of least privilege

6. **Monitoring**
   - Deploy Prometheus for metrics
   - Use Grafana for visualization
   - Set up alerting for critical metrics

## 📚 Additional Resources

### Docker Documentation

- [Docker Official Documentation](https://docs.docker.com/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

### Kubernetes Documentation

- [Kubernetes Official Docs](https://kubernetes.io/docs/)
- [Kind Documentation](https://kind.sigs.k8s.io/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

### Go & Backend

- [Go Documentation](https://golang.org/doc/)
- [Gin Web Framework](https://gin-gonic.com/)
- [MongoDB Go Driver](https://docs.mongodb.com/drivers/go/)

### MongoDB

- [MongoDB Documentation](https://docs.mongodb.com/)
- [MongoDB Replica Sets](https://docs.mongodb.com/manual/replication/)
- [Mongo Express](https://github.com/mongo-express/mongo-express)

## 📝 API Endpoints

### Health Check

```bash
GET /health
curl http://localhost:8080/health
# Response: {"database":"ok","cache":"ok"}
```

### Authentication

```bash
POST /auth/register
POST /auth/login
POST /auth/logout
GET /auth/username-check/:username
```

### Protected Routes (require JWT token)

```bash
GET /tasks - List all tasks
POST /tasks - Create new task
GET /tasks/:id - Get specific task
PUT /tasks/:id - Update task
DELETE /tasks/:id - Delete task

GET /users/me - Get user profile
PUT /users/me - Update user profile
DELETE /users/me - Delete account
PUT /users/me/password - Change password
```

### Documentation

```bash
GET /swagger/index.html - Swagger UI
GET /swagger/swagger.json - OpenAPI spec
```

## 🤝 Support & Contribution

For issues, questions, or improvements:

1. Check the troubleshooting section
2. Review Kubernetes events: `kubectl get events -n much-todo`
3. Check application logs for error messages
4. Consult official documentation links provided

## 📄 License

This project is part of an educational assessment. Follow institutional guidelines for usage.

---

**Last Updated**: January 2026
**Version**: 1.0.0
**Status**: Production Ready
