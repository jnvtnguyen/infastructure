## Installing NFS Subdir External Provisioner for NFS Storage on Kubernetes Clusters

#### Installing NFS Subdir External Provisioner on Helm
```
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --set nfs.server=10.0.0.8 --set nfs.path=/tank/kubernetes/nfs
```

## Uninstalling NFS Subdir External Provisioner
#### Uninstall NFS Subdir External Provisioner on Helm
```
helm uninstall nfs-subdir-external-provisioner
```
