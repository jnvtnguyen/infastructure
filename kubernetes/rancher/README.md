## Installing Rancher

#### Create the Kubernetes Namespace for Rancher & Cert Manager
```
kubectl apply -f namespace.yaml
```

#### Install Cert Manager on Helm
```
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --set installCRDs=true --namespace cert-manager 
```

#### Install Rancher on Helm
```
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo update
helm install rancher rancher-stable/rancher --namespace cattle-system --set hostname=rancher.local.syspawn.com
```

#### Wait for Roll Out of Rancher
```
kubectl --namespace cattle-system rollout status deploy/rancher
```

## Uninstalling Rancher
#### Uninstall Cert Manager on Helm
```
helm uninstall cert-manager --namespace cert-manager
```

#### Uninstall Rancher on Helm
```
helm uninstall rancher --namespace cattle-system
```

#### Delete Namespaces
```
kubectl delete namespace cert-manager cattle-system
```
