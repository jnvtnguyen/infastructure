## Installing Emberstack Kubernetes Reflector

#### Create Reflector Namespace
```
kubectl apply -f namespace.yaml
```

#### Installing Emberstack Kubernetes Reflector on Helm
```
helm repo add emberstack https://emberstack.github.io/helm-charts
helm repo update
helm install reflector emberstack/reflector --namespace reflector
```
