locals {
  # Flatten all Kubernetes Clusters Worker Node Definition in Order to get a Single Machine Array
  kubernetes_worker_machines = flatten([
    for cindex, cluster in var.kubernetes_clusters: [
      for worker_node in var.kubernetes_clusters[cindex].worker_nodes_definition: {
        name = worker_node.name
        ip_address = worker_node.ip_address
        target_node = worker_node.target_node
        user = cluster.user
        sockets = worker_node.sockets
        cores = worker_node.cores
        memory = worker_node.memory
        balloon = worker_node.balloon
        onboot = worker_node.onboot
        description = "${cluster.name} Worker Kubernetes Node"
        api_server_ip_address = cluster.api_server_ip_address
        cluster_index = cindex
      }
    ]
  ])
}

# Resource to Create Kubernetes Worker Machines on Proxmox
resource "proxmox_vm_qemu" "kubernetes_worker_machines" {
  for_each = {for w in local.kubernetes_worker_machines: w.name => w}

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
  ciuser = each.value.user
  sshkeys = <<EOF
  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCVL2k/3qfa/Y6qkcb73vvq0KGBlCqGw737Cx3A+gtQwbWW8jtrwiN8tiEf4WCboOKdzLffhuJWl5k+x9+yUqXXLyNBwNBHF36BmOpPWyCq5p+1XgwikybheBwnYpf5fCbdjyuYrftSHxHLmKEtPconOGs/XylloiS+9mcVxUkiWvlUDyrMoumhEGr3KFMclhSy5Wv86BkOeX60HD8JXy/e2Tqf8i/tl0s+6P0uFD8cGQsyLt6f2tcJQkmgDURl/b6noX9HhqEUAuvueresJB4jaLrZ5Renx2uINJiMqlOyYfgCXbc7Ntw5VNizdW+cDvROPfvUUS6Wysdv3K9YKsJHgPZUIio21eTj57A1kWXqSfE2FSnqRRiPtu6mdNre980CRlOP45jCTwWOLmeE3WUEfsy9dspF6KLcG0b5/g0rw6iLYocVGpgclvWcdO/4g7oWQJzLJyiWuOKT6608JwmOitdMFyw/jOAhhLC/f65uj8zkqi/2uIsUB4CGsbr/cl8= jnguyen@JNLAPTOP
  EOF
}

# Resource to Install k3s on Kubernetes Clusters Worker Machines
resource "null_resource" "kubernetes_worker_machines_k3s_install" {
  depends_on = [
    proxmox_vm_qemu.kubernetes_worker_machines,
    null_resource.kubernetes_other_master_machines_k3s_install
  ]

  for_each = {for w in local.kubernetes_worker_machines: w.name => w}

  triggers = {
    machines = join(",", [for m in proxmox_vm_qemu.kubernetes_master_machines: m.name])
  }

  connection {
    type = "ssh"
    host = each.value.ip_address
    user = "administrator"
    port = 22
  }

  provisioner "remote-exec" {
    inline = [
      "sudo curl -sfL https://get.k3s.io | K3S_URL=https://${each.value.api_server_ip_address}:6443 K3S_TOKEN=${nonsensitive(random_password.k3s_cluster_secret[each.value.cluster_index].result)} sh -",
      "sleep 1"
    ]
  }
}
