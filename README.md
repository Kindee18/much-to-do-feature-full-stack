# MuchTodo Containerization and Kubernetes Deployment

This repository contains the containerization and Kubernetes deployment setup for the MuchTodo backend application.

## Prerequisites

- Docker
- Docker Compose
- Kind (Kubernetes in Docker)
- kubectl

## Phase 1: Docker Setup

The application is containerized using a multi-stage Golang build for optimization and security.

### 1. Build the Docker Image
To build the optimized backend image:
```bash
./scripts/docker-build.sh
```

### 2. Run with Docker Compose
To start the backend and MongoDB containers locally for development:
```bash
./scripts/docker-run.sh
```
The application will be accessible at `http://localhost:3000`.

### 3. Health Check
Verify the running status:
```bash
curl http://localhost:3000/health
```

---

## Phase 2: Kubernetes Deployment

The application is deployed to a local Kubernetes cluster using Kind, with full resource management and persistence.

### 1. Deploy to Kubernetes
To create a Kind cluster and deploy all manifests (Namespace, Secrets, ConfigMaps, PVC, Deployments, Services, and Ingress):
```bash
./scripts/k8s-deploy.sh
```

### 2. Verify Resources
```bash
# Check Pods
kubectl get pods -n muchtodo-ns

# Check Services
kubectl get svc -n muchtodo-ns

# Check Ingress
kubectl get ingress -n muchtodo-ns
```

### 3. Accessing the Application
You can access the backend via port-forwarding:
```bash
kubectl port-forward svc/backend 3000:80 -n muchtodo-ns
```
Then visit `http://localhost:3000/health`.

### 4. Cleanup
To delete the Kind cluster and all associated resources:
```bash
./scripts/k8s-cleanup.sh
```

## Manifests Structure
- `kubernetes/namespace.yaml`: Dedicated namespace `muchtodo-ns`.
- `kubernetes/mongodb/`: MongoDB Deployment (1 replica), Service, PVC, Secret, and ConfigMap.
- `kubernetes/backend/`: Backend Deployment (2 replicas), Service, Secret, and ConfigMap.
- `kubernetes/ingress.yaml`: Ingress resource for path-based routing.

## Evidence
Specific evidence of the deployment and verification can be found in the `evidence/` folder:
- `docker-build-process.txt`: Docker build logs.
- `docker-compose-running.txt`: Compose container status.
- `docker-compose-response.txt`: App response via Docker Compose.
- `kind-cluster-creation.txt`: Kind cluster status.
- `k8s-deployments-running.txt`: Deployment status.
- `k8s-pod-status.txt`: Multi-replica pod status.
- `k8s-services.txt`: Service configurations.
- `k8s-ingress-status.txt`: Ingress configuration.
- `k8s-ingress-accessibility.txt`: Accessibility verification (via Ingress).
- `backend-logs.txt`: Kubernetes backend logs.
