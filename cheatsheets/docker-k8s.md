# Docker & Kubernetes Cheat Sheet

## Docker
```bash
# Build
docker build -t myapp:latest .

# Run
docker run -d -p 8000:8000 --name myapp myapp:latest

# Manage
docker ps
docker logs <container>
docker exec -it <container> bash
docker stop <container>
docker rm <container>

# Compose
docker compose up -d
docker compose down
docker compose logs -f
```

## Kubernetes
```bash
# Apply manifests
kubectl apply -f deployment.yaml

# Get resources
kubectl get pods -n mlops
kubectl get svc
kubectl get hpa

# Describe/Logs
kubectl describe pod <pod> -n mlops
kubectl logs <pod> -n mlops
kubectl logs -f <pod> -n mlops --tail=50

# Debug
kubectl exec -it <pod> -n mlops -- bash
kubectl port-forward svc/api 8000:80 -n mlops

# Scale
kubectl scale deployment api --replicas=5 -n mlops

# Delete
kubectl delete pod <pod> -n mlops
```
