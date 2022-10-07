terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
  } 
}

# Proxmox Authentication Variables
variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type = string
}

variable "proxmox_api_token_secret" {
  type = string
}

# Proxmox Provider Configuration
provider "proxmox" {
  pm_api_url = var.proxmox_api_url
  pm_api_token_id = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret

  pm_tls_insecure = true  
  pm_parallel = 4
}
