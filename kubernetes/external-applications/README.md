## Creating External Ingress for Applications that Aren't Within Kubernetes Cluster
Note: This is only used to provide https, tls & certificate for external applications like Proxmox or TrueNAS

#### Create External Applications Namespace
```
kubectl apply -f namespace.yaml
```
