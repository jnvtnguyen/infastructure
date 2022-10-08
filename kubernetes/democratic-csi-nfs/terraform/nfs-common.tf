resource "null_resource" "machines_install_nfs_common" {
  for_each = {for m in var.machines: m => m}

  connection {
    type = "ssh"
    host = each.value
    user = "administrator" 
    port = 22
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt install nfs-common -y",
      "sleep 1"
    ]
  }
}
