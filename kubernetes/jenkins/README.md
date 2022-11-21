## Installing Jenkins on a Kubernetes Cluster

#### Creating Resources
```
kubectl apply -f namespace.yaml
kubectl apply -f service-account.yaml
kubectl apply -f ingress.yaml
kubectl apply -f pvc.yaml
```
#### Installing Jenkins on Helm
```
helm repo add jenkinsci https://charts.jenkins.io
helm repo update
helm install jenkins jenkinsci/jenkins -n jenkins -f values.yaml
```
