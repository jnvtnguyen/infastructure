locals {
  # Flatten all Kubernetes Clusters Master Node Definition in Order to get a Single Machine Array
  kubernetes_master_machines = flatten([
    for cindex, cluster in var.kubernetes_clusters: [ 
      for mindex, master_node in var.kubernetes_clusters[cindex].master_nodes_definition: { 
        name = master_node.name
        ip_address = master_node.ip_address
        target_node = master_node.target_node
        sockets = master_node.sockets
        cores = master_node.cores
        memory = master_node.memory
        balloon = master_node.balloon
        onboot = master_node.onboot
        description = "${cluster.name} Master Kubernetes Node"
        api_server_ip_address = cluster.api_server_ip_address
        network_interface = cluster.network_interface
        is_first_in_cluster = (mindex == 0)
        kube_vip_version = cluster.kube_vip_version
        metallb_speaker_version = cluster.metallb_speaker_version
        metallb_controller_version = cluster.metallb_controller_version
        metallb_ip_address_range = cluster.metallb_ip_address_range
        disable_traefik = cluster.disable_traefik
        cluster_index = cindex
      }
    ]
  ])
  kubernetes_clusters_count = length(var.kubernetes_clusters)
}

# Used to Generate the Random k3s Cluster Secret
resource "random_password" "k3s_cluster_secret" {
  count = local.kubernetes_clusters_count
  length = 48
  special = false
}

# Resource to Create Kubernetes Master Machines on Proxmox
resource "proxmox_vm_qemu" "kubernetes_master_machines" {
  for_each = {for m in local.kubernetes_master_machines: m.name => m}

  name = each.value.name
  desc = each.value.description
  target_node = each.value.target_node

  agent = 1

  clone = "ubuntu-server-jammy"
  sockets = each.value.sockets
  cores = each.value.cores
  cpu = "host"
  memory = each.value.memory
  balloon = each.value.balloon

  onboot = each.value.onboot

  network {
    bridge = "vmbr0"
    model = "virtio"
  }

  disk {
    storage = "local"
    type = "virtio"
    size = "32G"
  }

  os_type = "cloud-init"
  ipconfig0 = "ip=${each.value.ip_address}/24,gw=10.0.0.1"
  nameserver = "10.0.0.12"
  ciuser = "administrator"
  sshkeys = <<EOF
  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCXREtrQCkD8QM1UE6H/ClAF+bb5aMqzPz49V9fzJDGCHcaPuBmNpzQOSqVvg1fwflSLbKiESBhVI+uD2g3mgWClUl5rTJH0qHQ5Tsg+bqd83fbtYRYoGeAmTX6/3i1jVA0KH3tN0tLNb+mR8fQPltFTIFdZHsfmrQZICZyzt8L+sb9PDsa/6KjpoxTqSZPXmHGJz7iKS2PkTUbX29v4beyfdXapxiHNn4F391MXrokYq0JmYEV7Mr6RLwEGsf5y0q6tyfM7JF6tAvnBl2cf8DFGbgzfhdh9Ek6iCeJCX9zbvH152+LadpfR/A/Hvc10p9zRNHljxYyzD0VqnKQ3lViK+aRQqngHIHvPFspXgcLvyndW6xaMBNLuXvWxX/ojCbOISKW02KNuVVDmwOX1sjQA6JQ2Y/llumoaEvJv13pSMBojocw4lf6gSqHFjQacCe/p/4m4l0YgKOFciCV7K5q/1mRkJB+4parocjyvC+tUB5411X+yV0Y4Y8UDrZ6qNM= jnguyen@lxmint
  EOF
}

# Resource to Install k3s on First Master Machine
resource "null_resource" "kubernetes_first_master_machine_k3s_install" {
  depends_on = [
    proxmox_vm_qemu.kubernetes_master_machines,
    random_password.k3s_cluster_secret
  ]

  for_each = {
    for m in local.kubernetes_master_machines: m.name => m
    if m.is_first_in_cluster
  }

  connection {
    type = "ssh"
    host = each.value.ip_address
    user = "administrator"
    port = 22
  }

  provisioner "remote-exec" {
    inline = [
      "curl -sfL https://get.k3s.io | K3S_TOKEN=${nonsensitive(random_password.k3s_cluster_secret[each.value.cluster_index].result)} sh -s - server --cluster-init --node-taint CriticalAddonsOnly=true:NoExecute --tls-san https://${each.value.api_server_ip_address} --disable servicelb ${each.value.disable_traefik ? "--disable traefik" : ""}",
      "sleep 1"
    ]
  }
}

# Resource to Create k3s Temp Folder on First Master Machine
resource "null_resource" "kubernetes_first_master_machine_create_k3s_temp_folder" {
  depends_on = [
    null_resource.kubernetes_first_master_machine_k3s_install
  ]

  for_each = {
    for m in local.kubernetes_master_machines: m.name => m
    if m.is_first_in_cluster
  }

  connection {
    type = "ssh"
    host = each.value.ip_address
    user = "administrator"
    port = 22
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /tmp/k3s",
      "sleep 1"
    ]
  }
}

# Resource to Install Kube Vip on First Master Machine for HA
resource "null_resource" "kubernetes_first_master_machine_install_kube_vip" {
  depends_on = [
    null_resource.kubernetes_first_master_machine_create_k3s_temp_folder
  ]

  for_each = {
    for m in local.kubernetes_master_machines: m.name => m
    if m.is_first_in_cluster
  }

  connection {
    type = "ssh"
    host = each.value.ip_address
    user = "administrator"
    port = 22
  }

  provisioner "file" {
    source = "templates/kube-vip-rbac.yaml.tftpl"
    destination = "/tmp/k3s/kube-vip-rbac.yaml"
  }

  provisioner "file" {
    content = templatefile("templates/kube-vip.yaml.tftpl", {
      kube_vip_network_interface = each.value.network_interface,
      kube_vip_ip_address = each.value.api_server_ip_address,
      kube_vip_version = each.value.kube_vip_version
    })
    destination = "/tmp/k3s/kube-vip.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/k3s/kube-vip-rbac.yaml /var/lib/rancher/k3s/server/manifests/kube-vip-rbac.yaml",
      "sudo mv /tmp/k3s/kube-vip.yaml /var/lib/rancher/k3s/server/manifests/kube-vip.yaml",
      "sleep 1"
    ] 
  }
}

# Resource to Install Metallb on First Master Machine
resource "null_resource" "kubernetes_first_master_machine_install_metallb" {
  depends_on = [
    null_resource.kubernetes_first_master_machine_create_k3s_temp_folder
  ]

  for_each = {
    for m in local.kubernetes_master_machines: m.name => m
    if m.is_first_in_cluster
  }

  connection {
    type = "ssh"
    host = each.value.ip_address
    user = "administrator"
    port = 22
  }

  provisioner "file" {
    content = templatefile("templates/metallb.yaml.tftpl", {
      metallb_speaker_version = each.value.metallb_speaker_version,
      metallb_controller_version = each.value.metallb_controller_version
    })
    destination = "/tmp/k3s/metallb.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/k3s/metallb.yaml /var/lib/rancher/k3s/server/manifests/metallb.yaml",
      "sleep 1"
    ]
  }
}

# Resource to Install k3s on Other Master Machines
resource "null_resource" "kubernetes_other_master_machines_k3s_install" {
  depends_on = [
    null_resource.kubernetes_first_master_machine_install_kube_vip 
  ]

  for_each = {
    for m in local.kubernetes_master_machines: m.name => m
    if !m.is_first_in_cluster
  }

  connection {
    type = "ssh"
    host = each.value.ip_address
    user = "administrator"
    port = 22
  }

  provisioner "remote-exec" {
    inline = [
      "curl -sfL https://get.k3s.io | K3S_TOKEN=${nonsensitive(random_password.k3s_cluster_secret[each.value.cluster_index].result)} sh -s - server --node-taint CriticalAddonsOnly=true:NoExecute --server https://${each.value.api_server_ip_address}:6443 --tls-san https://${each.value.api_server_ip_address} --disable servicelb ${each.value.disable_traefik ? "--disable traefik" : ""}",
      "until sudo kubectl get node ${each.value.name}; do sleep 1; done"
    ]
  }
}

# Resource to Configure Metallb IPAdressRange
resource "null_resource" "kubernetes_first_master_machine_apply_metallb_ip_address_range" {
  depends_on = [
    null_resource.kubernetes_worker_machines_k3s_install
  ]

  for_each = {
    for m in local.kubernetes_master_machines: m.name => m
    if m.is_first_in_cluster
  }

  connection {
    type = "ssh"
    host = each.value.ip_address
    user = "administrator"
    port = 22
  }

  provisioner "file" {
    content = templatefile("templates/metallb-ip-address-range.yaml.tftpl", {
      metallb_ip_address_range = each.value.metallb_ip_address_range
    })
    destination = "/tmp/k3s/metallb-ip-address-range.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "until sudo kubectl wait deployment controller --for condition=Available=True --namespace metallb-system --timeout 120s; do sleep 1; done",
      "until sudo kubectl apply -f /tmp/k3s/metallb-ip-address-range.yaml --timeout=120s; do sleep 1; done",
    ]
  }
}

# Resource to Remove k3s Temp Folder on First Master Machine
resource "null_resource" "kubernetes_first_master_machine_remove_k3s_temp_folder" {
  depends_on = [
    null_resource.kubernetes_first_master_machine_install_kube_vip,
    null_resource.kubernetes_first_master_machine_install_metallb,
    null_resource.kubernetes_first_master_machine_apply_metallb_ip_address_range
  ]

  for_each = {
    for m in local.kubernetes_master_machines: m.name => m
    if m.is_first_in_cluster
  }

  connection {
    type = "ssh"
    host = each.value.ip_address
    user = "administrator"
    port = 22
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /tmp/k3s",
      "sleep 1"
    ]
  }
}

# Resource to Copy Kube Config to Home Directory (administrator) for Personal Use
resource "null_resource" "kubernetes_master_machines_copy_kube_config_to_home" {
  depends_on = [
    null_resource.kubernetes_other_master_machines_k3s_install
  ]

  for_each = {for m in local.kubernetes_master_machines: m.name => m}

  connection {
    type = "ssh"
    host = each.value.ip_address
    user = "administrator"
    port = 22
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p ~/.kube",
      "sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config",
      "sudo chown -R $USER ~/.kube/config",
      "sleep 1"
    ]
  }
}

# Resource to Configure API Server IP Address to the Kube Vip IP Address
resource "null_resource" "kubernetes_master_machines_configure_api_server_ip_address" {
  depends_on = [
    null_resource.kubernetes_master_machines_copy_kube_config_to_home
  ]

  for_each = {for m in local.kubernetes_master_machines: m.name => m}

  connection {
    type = "ssh"
    host = each.value.ip_address
    user = "administrator"
    port = 22
  }

  provisioner "remote-exec" {
    inline = [
      "sudo kubectl config set-cluster default --server=https://${each.value.api_server_ip_address}:6443 --kubeconfig ~/.kube/config",
      "sleep 1"
    ]
  }
}

# Resource to Remove Unused Manifests on the Master Machines from Initial Install
resource "null_resource" "kubernetes_master_machines_remove_manifests" {
  depends_on = [
    null_resource.kubernetes_other_master_machines_k3s_install
  ]

  for_each = {for m in local.kubernetes_master_machines: m.name => m}

  connection {
    type = "ssh"
    host = each.value.ip_address
    user = "administrator"
    port = 22
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /var/lib/rancher/k3s/server/manifests/*",
      "sleep 1"
    ]
  }
}
