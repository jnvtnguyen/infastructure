# Resource to Create Machines on Proxmox
resource "proxmox_vm_qemu" "machines" {
  for_each = {for m in var.machines: m.name => m}

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
  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCXREtrQCkD8QM1UE6H/ClAF+bb5aMqzPz49V9fzJDGCHcaPuBmNpzQOSqVvg1fwflSLbKiESBhVI+uD2g3mgWClUl5rTJH0qHQ5Tsg+bqd83fbtYRYoGeAmTX6/3i1jVA0KH3tN0tLNb+mR8fQPltFTIFdZHsfmrQZICZyzt8L+sb9PDsa/6KjpoxTqSZPXmHGJz7iKS2PkTUbX29v4beyfdXapxiHNn4F391MXrokYq0JmYEV7Mr6RLwEGsf5y0q6tyfM7JF6tAvnBl2cf8DFGbgzfhdh9Ek6iCeJCX9zbvH152+LadpfR/A/Hvc10p9zRNHljxYyzD0VqnKQ3lViK+aRQqngHIHvPFspXgcLvyndW6xaMBNLuXvWxX/ojCbOISKW02KNuVVDmwOX1sjQA6JQ2Y/llumoaEvJv13pSMBojocw4lf6gSqHFjQacCe/p/4m4l0YgKOFciCV7K5q/1mRkJB+4parocjyvC+tUB5411X+yV0Y4Y8UDrZ6qNM= jnguyen@lxmint
  EOF
}

# Resource to Install Docker on Docker Machines
resource "null_resource" "machines_install_docker" {
  for_each = {
    for m in var.machines: m.name => m
    if m.install_docker
  }

  triggers = { 
    machines = join(",", flatten([for m in var.machines: [for pm in proxmox_vm_qemu.machines: pm.name if m.name == pm.name && m.install_docker]]))
  }

  connection {
    type = "ssh"
    host = each.value.ip_address
    user = "administrator"
    port = 22
  }

  provisioner "remote-exec" {
    inline = [
      "while sudo fuser /var/{lib/{dpkg,apt/lists},cache/apt/archives}/lock >/dev/null 2>&1; do sleep 1; done",
      "sudo apt-get update",
      "sudo apt-get install ca-certificates curl gnupg lsb-release",
      "sudo mkdir -p /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
      "echo 'deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin",
      "sleep 1"
    ]
  }
}
