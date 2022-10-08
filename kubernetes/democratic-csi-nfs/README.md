## Installing Democratic CSI NFS Provisioner for NFS Storage on Kubernetes Clusters

#### Creating Democratic CSI Namespace
```
kubectl apply -f namespace.yaml
```

#### Server/Node Prerequisites

You must have nfs-common installed on all nodes and is automated in the terraform folder

#### Installing Democratic CSI on Helm

Before installing Democratic CSI on Helm, you must create your own values.yaml file from the provided code below
```
csiDriver:
  name: "org.democratic-csi.truenas-nfs"

storageClasses:
- name: truenas-nfs-csi 
  defaultClass: false
  reclaimPolicy: Retain
  volumeBindingMode: Immediate
  allowVolumeExpansion: true
  parameters:
    fsType: nfs
  mountOptions:
  - noatime
  - nfsvers=4
  secrets:
    provisioner-secret:
    controller-publish-secret:
    node-stage-secret:
    node-publish-secret:
    controller-expand-secret:

driver:
  config:
    driver: freenas-api-nfs
    instance_id: 
    httpConnection:
      protocol: http
      host: 10.0.0.8
      port: 80
      username: root
      apiKey: <api-key>
      allowInsecure: true
    zfs:
      datasetParentName: tank/kubernetes/...
      detachedSnapshotsDatasetParentName: tank/kubernetes/...
      datasetEnableQuotas: true
      datasetEnableReservation: false
      datasetPermissionsUser: 0
      datasetPermissionsMode: "0777"
      datasetPermissionsGroup: 0
    nfs:
      shareHost: 10.0.0.8
      shareAlldirs: false
      shareAllowedHosts: []
      shareAllowedNetworks: []
      shareMaprootGroup: root
      shareMaprootUser: root
      shareMapallUser: ""
      shareMapallGroup: ""  
```

Installing Democratic CSI on Helm
```
helm repo add democratic-csi https://democratic-csi.github.io/charts/
helm repo update
helm install truenas-nfs democratic-csi/democratic-csi --values <values.template.yaml> --namespace democratic-csi
```

## Uninstalling Democratic CSI NFS Provisioner

#### Uninstall Democratic CSI on Helm
```
helm uninstall nfs-subdir-external-provisioner
```

#### Delete Democratic CSI Namespace
```
kubectl delete namespace democratic-csi
```
