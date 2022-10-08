## Installing Democratic CSI NFS Provisioner for NFS Storage on Kubernetes Clusters

#### Creating Democratic CSI Namespace
```
kubectl apply -f namespace.yaml
```

#### Server/Node Prerequisites

You must have nfs-common installed on all nodes and is automated in the terraform folder

#### Installing Democratic CSI NFS Provisioner on Helm

Before installing Democratic CSI NFS Provisioner on Helm, you must create your own values.yaml file from the provided values.template.yaml or the code below
```
driver: freenas-api-nfs
instance_id:
httpConnection:
  protocol: http
  host: 10.0.0.8
  port: 80
  username: root
  apiKey: 1-uLf8uCjZXCEWQ5WPWAbwE3BgpsgKOb3pXEH23tgVRsy29qwitCW4R5fLTBaVi23J
  allowInsecure: true
zfs:
  datasetParentName: tank/kubernetes/...
  detachedSnapshotsDatasetParentName: tank/kubernetes/...
  datasetEnableQuotas: true
  datasetEnableReservation: false
  datasetPermissionsMode: "0777"
  datasetPermissionsUser: 0
  datasetPermissionsGroup: 0
nfs:
  shareHost: 10.0.0.8
  shareAlldirs: false
  shareAllowedHosts: []
  shareAllowedNetworks: []
  shareMaprootUser: root
  shareMaprootGroup: root
  shareMapallUser: ""
  shareMapallGroup: ""
```

Installing Democratic CSI NFS Provisioner on Helm
```
helm repo add democratic-csi https://democratic-csi.github.io/charts/
helm repo update
helm install \
--install \
--values <values.template.yaml> \
--namespace democratic-csi \
zfs-nfs democratic-csi/democratic-csi
```

## Uninstalling Democratic CSI NFS Provisioner

#### Uninstall Democratic CSI NFS Provisioner on Helm
```
helm uninstall nfs-subdir-external-provisioner
```

#### Delete Democratic CSI Namespace
```
kubectl delete namespace democratic-csi
```
