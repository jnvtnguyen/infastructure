## Installing ArgoCD on a Kubernetes Cluster

#### Creating ArgoCD Namespace
```
kubectl apply -f namespace.yaml
```

#### Installing ArgoCD via Manifest
```
kubectl apply -f install.yaml --namespace argocd
```

#### Creating ArgoCD Ingress
```
kubectl apply -f ingress.yaml
```
