## Installing Traefik on a Kubernetes Cluster

#### Creating Namespace Resources for Traefik & Cert Manager
```
kubectl apply -f namespace.yaml
```

#### Installing Traefik on Helm
```
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
helm install --namespace=traefik traefik traefik/traefik --values=values.yaml
```

#### Creating Dashboard Authentication
```
sudo apt-get update
sudo apt-get intall apache2-utils
htpasswd -nb admin <password> | openssl base64

kubectl apply -f dashboard-authentication-secret.yaml
kubectl apply -f dashboard-authentication-middleware.yaml
kubectl apply -f dashboard-ingress.yaml
```

#### Installing Cert Manager on Helm
```
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --values cert-manager/values.yaml
```
