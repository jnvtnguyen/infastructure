# Variable Definition for Machines
variable "machines" {
  type = list(object({
    name = string
    description = string
    ip_address = string
    target_node = optional(string, "pve1")
    user = optional(string, "admin")
    sockets = optional(number, 1)
    cores = optional(number, 8)
    memory = optional(number, 8192)
    balloon = optional(number, 1)
    onboot = optional(bool, true)
    install_docker = optional(bool, false)
  }))
}
