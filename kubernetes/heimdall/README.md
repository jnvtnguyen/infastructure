## Installing Heimdall on a Kubernetes Cluster

#### Creating Resources & Deploying Heimdall
```
kubectl apply -f namespace.yaml
kubectl apply -f pvc.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```
or
```
kubectl apply -f namespace.yaml
kubectl apply -f .
```
