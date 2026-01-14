# Evidence Collection Commands

## 1. Docker Build Evidence

```powershell
# Already completed - Image built successfully
docker images much-to-do
# Output: much-to-do   latest    279ca443291a   54.8MB
```

## 2. Kubernetes Deployment Commands

### Create Kind Cluster

```powershell
$env:PATH += ";C:\Program Files\Docker\Docker\resources\bin"
C:\kubectl\kind.exe create cluster --name much-todo-cluster
```

### Load Docker Image

```powershell
C:\kubectl\kind.exe load docker-image much-to-do:latest --name much-todo-cluster
```

### Deploy Namespace

```powershell
C:\kubectl\kubectl.exe apply -f kubernetes\namespace.yaml
```

### Deploy MongoDB

```powershell
C:\kubectl\kubectl.exe apply -f kubernetes\mongodb\mongodb-secret.yaml
C:\kubectl\kubectl.exe apply -f kubernetes\mongodb\mongodb-configmap.yaml
C:\kubectl\kubectl.exe apply -f kubernetes\mongodb\mongodb-pvc.yaml
C:\kubectl\kubectl.exe apply -f kubernetes\mongodb\mongodb-deployment.yaml
C:\kubectl\kubectl.exe apply -f kubernetes\mongodb\mongodb-service.yaml
```

### Deploy Backend

```powershell
C:\kubectl\kubectl.exe apply -f kubernetes\backend\backend-secret.yaml
C:\kubectl\kubectl.exe apply -f kubernetes\backend\backend-configmap.yaml
C:\kubectl\kubectl.exe apply -f kubernetes\backend\backend-sa.yaml
C:\kubectl\kubectl.exe apply -f kubernetes\backend\backend-deployment.yaml
C:\kubectl\kubectl.exe apply -f kubernetes\backend\backend-service.yaml
```

### Deploy Ingress

```powershell
C:\kubectl\kubectl.exe apply -f kubernetes\ingress.yaml
```

## 3. Verification Commands

### Check Pods

```powershell
C:\kubectl\kubectl.exe get pods -n much-todo
C:\kubectl\kubectl.exe get pods -n much-todo -o wide
```

### Check Services

```powershell
C:\kubectl\kubectl.exe get svc -n much-todo
```

### Check Deployments

```powershell
C:\kubectl\kubectl.exe get deployments -n much-todo
```

### Check Events

```powershell
C:\kubectl\kubectl.exe get events -n much-todo
```

### View Logs

```powershell
# Backend logs
C:\kubectl\kubectl.exe logs -f deployment/backend -n much-todo

# MongoDB logs
C:\kubectl\kubectl.exe logs -f deployment/mongodb -n much-todo
```

### Test Application

```powershell
# Via NodePort
curl http://localhost:8080/health

# Via Port Forward
C:\kubectl\kubectl.exe port-forward -n much-todo svc/backend 8080:8080
curl http://localhost:8080/health
```

## 4. Screenshots Needed

1. **Docker Build**: Terminal showing successful build with image size
2. **Docker Images**: Output of `docker images` showing much-to-do:latest
3. **Kind Cluster**: Output showing cluster creation success
4. **Kubectl Context**: Output of `kubectl config current-context`
5. **Namespace**: Output of `kubectl get namespace much-todo`
6. **Pods Running**: `kubectl get pods -n much-todo` with all Running
7. **Services**: `kubectl get svc -n much-todo` showing NodePort
8. **Deployments**: `kubectl get deployments -n much-todo`
9. **Health Check**: Browser or curl showing health endpoint response
10. **Logs**: Sample of backend pod logs showing successful startup

## 5. Cleanup Commands

```powershell
# Delete namespace (removes all resources)
C:\kubectl\kubectl.exe delete namespace much-todo

# Delete cluster
C:\kubectl\kind.exe delete cluster --name much-todo-cluster
```
