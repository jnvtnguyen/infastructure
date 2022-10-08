## Installing NFS Subdir External Provisioner for NFS Storage on Kubernetes Clusters

#### Creating NFS Subdir External Provisioner Namespace
```
kubectl apply -f namespace.yaml
```

#### Installing NFS Subdir External Provisioner on Helm
```
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm repo update
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
--namespace nfs-subdir-external-provisioner \
--set nfs.mountOptions={nfsvers=4} \
--set nfs.server=10.0.0.8 \
--set nfs.path=/tank/kubernetes/...
```

## Uninstalling NFS Subdir External Provisioner
#### Uninstall NFS Subdir External Provisioner on Helm
```
helm uninstall nfs-subdir-external-provisioner
```
