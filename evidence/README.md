# MuchToDo Container Assessment - Evidence Documentation

This directory contains the logs and verification results from the containerization and Kubernetes deployment of the MuchTodo application.

## 1. Docker Build Evidence
- **Image Name**: `muchtodo-backend:latest`
- **Build Strategy**: Multi-stage build using `golang:1.25-alpine`
- **Security**: Implements a non-root `appuser`.
- **Optimization**: Layer caching optimized by copying `go.mod`/`go.sum` first.
- **Evidence File**: [`docker-build-process.txt`](docker-build-process.txt)

## 2. Docker Compose Evidence
- **Services**: `backend` (port 3000) and `mongodb` (port 27017).
- **Functionality**: Verified health endpoint and MongoDB connectivity.
- **Evidence Files**: 
    - [`docker-compose-running.txt`](docker-compose-running.txt)
    - [`docker-compose-response.txt`](docker-compose-response.txt)

## 3. Kubernetes Deployment Evidence
- **Namespace**: `muchtodo-ns`
- **Backend**: Deployment (2 replicas) with liveness/readiness probes.
- **Database**: MongoDB Deployment with Persistent Volume Claim (1Gi).
- **Ingress**: Configured to expose the backend via `localhost` on Port 80.
- **Evidence Files**:
    - [`kind-cluster-creation.txt`](kind-cluster-creation.txt)
    - [`k8s-deployments-running.txt`](k8s-deployments-running.txt)
    - [`k8s-pod-status.txt`](k8s-pod-status.txt)
    - [`k8s-services.txt`](k8s-services.txt)
    - [`k8s-ingress-status.txt`](k8s-ingress-status.txt)
    - [`k8s-ingress-accessibility.txt`](k8s-ingress-accessibility.txt)
    - [`backend-logs.txt`](backend-logs.txt)

## 4. Automation Scripts
- `docker-build.sh`: Image creation.
- `docker-run.sh`: Local development setup via Compose.
- `k8s-deploy.sh`: Full cluster setup and manifest application.
- `k8s-cleanup.sh`: Removal of all Kubernetes and Kind resources.

## 5. Summary Status: ✅ READY FOR SUBMISSION
All technical requirements, including optimized containerization, persistent storage, high availability (2 replicas), and ingress routing, have been implemented and verified.
