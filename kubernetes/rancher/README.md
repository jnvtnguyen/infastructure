### Creating Rancher Installation on Rancher Cluster

#### Create the Kubernetes Namespace for Rancher, Traefik & Cert Manager
```
kubectl apply -f namespace.yaml
```

#### Install Traefik & Cert Manager

Traefik
```
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
helm install traefik traefik/traefik --namespace=traefik 
```

Cert Manager
```
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --set installCRDs=true --namespace cert-manager 
```

#### Wait for Creation of Cert Manager to Finish
```
kubectl get pods --namespace cattle-system
```

#### Install Rancher
```
helm install rancher rancher-stable/rancher --namespace cattle-system --set hostname=rancher.local.syspawn.com
```

#### Wait for Roll Out of Rancher
```
kubectl --namespace cattle-system rollout status deploy/rancher
```
