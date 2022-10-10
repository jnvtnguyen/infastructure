# Variable Definition for Kubernetes Clusters
variable "kubernetes_clusters" {
  type = list(object({
    name = string
    network_interface = string
    api_server_ip_address = string
    kube_vip_version = optional(string, "v0.5.0")
    metallb_speaker_version = optional(string, "v0.13.5")
    metallb_controller_version = optional(string, "v0.13.5")
    metallb_ip_address_range = string
    disable_traefik = optional(bool, true)
    user = optional(string, "admin")
    master_nodes_definition = list(object({
      name = string
      ip_address = string
      target_node = optional(string, "pve1")
      sockets = optional(number, 1)
      cores = optional(number, 8)
      memory = optional(number, 8192)
      balloon = optional(number, 1)
      onboot = optional(bool, true)
    }))
    worker_nodes_definition = list(object({
      name = string
      ip_address = string
      target_node = optional(string, "pve1")
      sockets = optional(number, 1)
      cores = optional(number, 8)
      memory = optional(number, 8192)
      balloon = optional(number, 1)
      onboot = optional(bool, true)
    }))
  }))
}
