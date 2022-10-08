locals {
  # Flatten all Kubernetes Clusters Worker Node Definition in Order to get a Single Machine Array
  kubernetes_worker_machines = flatten([
    for cindex, cluster in var.kubernetes_clusters: [
      for worker_node in var.kubernetes_clusters[cindex].worker_nodes_definition: {
        name = worker_node.name
        ip_address = worker_node.ip_address
        target_node = worker_node.target_node
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
  searchdomain = "local.syspawn.com"
  nameserver = "10.0.0.12"
  ciuser = "administrator"
  sshkeys = <<EOF
  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCXREtrQCkD8QM1UE6H/ClAF+bb5aMqzPz49V9fzJDGCHcaPuBmNpzQOSqVvg1fwflSLbKiESBhVI+uD2g3mgWClUl5rTJH0qHQ5Tsg+bqd83fbtYRYoGeAmTX6/3i1jVA0KH3tN0tLNb+mR8fQPltFTIFdZHsfmrQZICZyzt8L+sb9PDsa/6KjpoxTqSZPXmHGJz7iKS2PkTUbX29v4beyfdXapxiHNn4F391MXrokYq0JmYEV7Mr6RLwEGsf5y0q6tyfM7JF6tAvnBl2cf8DFGbgzfhdh9Ek6iCeJCX9zbvH152+LadpfR/A/Hvc10p9zRNHljxYyzD0VqnKQ3lViK+aRQqngHIHvPFspXgcLvyndW6xaMBNLuXvWxX/ojCbOISKW02KNuVVDmwOX1sjQA6JQ2Y/llumoaEvJv13pSMBojocw4lf6gSqHFjQacCe/p/4m4l0YgKOFciCV7K5q/1mRkJB+4parocjyvC+tUB5411X+yV0Y4Y8UDrZ6qNM= jnguyen@lxmint
  EOF
}

# Resource to Install k3s on Kubernetes Clusters Worker Machines
resource "null_resource" "kubernetes_worker_machines_k3s_install" {
  depends_on = [
    proxmox_vm_qemu.kubernetes_worker_machines,
    null_resource.kubernetes_other_master_machines_k3s_install
  ]

  for_each = {for w in local.kubernetes_worker_machines: w.name => w}

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
