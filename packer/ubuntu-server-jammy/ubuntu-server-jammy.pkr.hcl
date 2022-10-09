variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_token_id" {
    type = string
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
}
source "proxmox" "ubuntu-server-jammy-pve1" {
 
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"
    insecure_skip_tls_verify = true
    
    node = "pve1"
    vm_id = "8000"
    vm_name = "ubuntu-server-jammy"
    template_description = "Ubuntu Server Jammy Image"

    iso_file = "nas:iso/ubuntu-22.04.1-live-server-amd64.iso"

    iso_storage_pool = "local"
    unmount_iso = true

    qemu_agent = true

    scsi_controller = "virtio-scsi-pci"

    disks {
        disk_size = "32G"
        format = "qcow2"
        storage_pool = "local"
        storage_pool_type = "lvm"
        type = "virtio"
    }

    cores = "8"
    
    memory = "8192" 

    network_adapters {
        model = "virtio"
        bridge = "vmbr0"
        firewall = "false"
    } 

    cloud_init = true
    cloud_init_storage_pool = "local"

    boot_command = [
        "<esc><wait>",
        "e<wait>",
        "<down><down><down><end>",
        "<bs><bs><bs><bs><wait>",
        "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
        "<f10><wait>"
    ]
    boot = "c"
    boot_wait = "5s"

    http_directory = "http" 
    http_interface = "wlp4s0"

    ssh_username = "jnguyen"
    ssh_private_key_file = "~/.ssh/id_rsa"

    ssh_timeout = "20m"
}

build {
    name = "ubuntu-server-jammy"
    sources = ["source.proxmox.ubuntu-server-jammy-pve1"]

    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt -y autoremove --purge",
            "sudo apt -y clean",
            "sudo apt -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo rm -f /etc/netplan/00-installer-config.yaml",
            "sudo sync"
        ]
    }

    provisioner "file" {
        source = "files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }
}

source "proxmox" "ubuntu-server-jammy-pve2" {
 
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"
    insecure_skip_tls_verify = true
    
    node = "pve2"
    vm_id = "9000"
    vm_name = "ubuntu-server-jammy"
    template_description = "Ubuntu Server Jammy Image"

    iso_file = "nas:iso/ubuntu-22.04.1-live-server-amd64.iso"

    iso_storage_pool = "local"
    unmount_iso = true

    qemu_agent = true

    scsi_controller = "virtio-scsi-pci"

    disks {
        disk_size = "32G"
        format = "qcow2"
        storage_pool = "local"
        storage_pool_type = "lvm"
        type = "virtio"
    }

    cores = "8"
    
    memory = "8192" 

    network_adapters {
        model = "virtio"
        bridge = "vmbr0"
        firewall = "false"
    } 

    cloud_init = true
    cloud_init_storage_pool = "local"

    boot_command = [
        "<esc><wait>",
        "e<wait>",
        "<down><down><down><end>",
        "<bs><bs><bs><bs><wait>",
        "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
        "<f10><wait>"
    ]
    boot = "c"
    boot_wait = "5s"

    http_directory = "http" 
    http_interface = "wlp4s0"

    ssh_username = "jnguyen"
    ssh_private_key_file = "~/.ssh/id_rsa"

    ssh_timeout = "20m"
}

build {
    name = "ubuntu-server-jammy"
    sources = ["source.proxmox.ubuntu-server-jammy-pve2"]

    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt -y autoremove --purge",
            "sudo apt -y clean",
            "sudo apt -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo rm -f /etc/netplan/00-installer-config.yaml",
            "sudo sync"
        ]
    }

    provisioner "file" {
        source = "files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }
}
