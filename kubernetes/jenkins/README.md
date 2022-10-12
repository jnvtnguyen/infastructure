## Installing Jenkins on a Kubernetes Cluster

#### Creating Resources
```
kubectl apply -f namespace.yaml
kubectl apply -f service-account.yaml
```
or
```
kubectl apply -f namespace.yaml
kubectl apply -f .
```

#### Installing Jenkins on Helm
```
helm repo add jenkinsci https://charts.jenkins.io
helm repo update
helm install jenkins jenkinsci/jenkins -n jenkins -f jenkins-values.yaml
```
