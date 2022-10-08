## Installing ArgoCD on a Kubernetes Cluster

#### Creating ArgoCD Namespace
```
kubectl apply -f namespace.yaml
```

#### Installing ArgoCD via Manifest
```
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/ha/install.yaml --namespace argocd
```
