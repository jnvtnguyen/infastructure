# Variable Declaration of Kubernetes Clusters
kubernetes_clusters = [
  {
    name = "Rancher"
    network_interface = "eth0",
    api_server_ip_address = "10.0.0.50"
    metallb_ip_address_range = "10.0.0.51-10.0.0.60"
    disable_traefik = false
    master_nodes_definition = [
      {
        name = "rmkb1",
        ip_address = "10.0.0.20",
        target_node = "pve1"
      },
      {
        name = "rmkb2",
        ip_address = "10.0.0.21",
        target_node = "pve1"
      },
      {
        name = "rmkb3",
        ip_address = "10.0.0.22",
        target_node = "pve1"
      }
    ],
    worker_nodes_definition = [
      {
        name = "rwkb1",
        ip_address = "10.0.0.23",
        target_node = "pve1"
      },
      {
        name = "rwkb2",
        ip_address = "10.0.0.24",
        target_node = "pve1"
      }
    ] 
  },
  {
    name = "Internal"
    network_interface = "eth0",
    api_server_ip_address = "10.0.0.60"
    metallb_ip_address_range = "10.0.0.61-10.0.0.70"
    master_nodes_definition = [ {
        name = "imkb1",
        ip_address = "10.0.0.25",
        target_node = "pve2"
      },
      {
        name = "imkb2",
        ip_address = "10.0.0.26",
        target_node = "pve2"
      },
      {
        name = "imkb3",
        ip_address = "10.0.0.27",
        target_node = "pve1"
      }
    ],
    worker_nodes_definition = [
      {
        name = "iwkb1",
        ip_address = "10.0.0.28",
        target_node = "pve2"
      },
      {
        name = "iwkb2",
        ip_address = "10.0.0.29",
        target_node = "pve2"
      },
      {
        name = "iwkb3",
        ip_address = "10.0.0.30",
        target_node = "pve2"
      },
      {
        name = "iwkb4",
        ip_address = "10.0.0.31",
        target_node = "pve1"
      },
      {
        name = "iwkb5",
        ip_address = "10.0.0.32",
        target_node = "pve1"
      }
    ] 
  },
  {
    name = "Staging"
    network_interface = "eth0",
    api_server_ip_address = "10.0.0.70"
    metallb_ip_address_range = "10.0.0.71-10.0.0.80"
    master_nodes_definition = [
      {
        name = "smkb1",
        ip_address = "10.0.0.33",
        target_node = "pve2"
      },
      {
        name = "smkb2",
        ip_address = "10.0.0.34",
        target_node = "pve2"
      },
      {
        name = "smkb3",
        ip_address = "10.0.0.35",
        target_node = "pve1"
      }
    ],
    worker_nodes_definition = [
      {
        name = "swkb1",
        ip_address = "10.0.0.36",
        target_node = "pve2"
      },
      {
        name = "swkb2",
        ip_address = "10.0.0.37",
        target_node = "pve2"
      },
      {
        name = "swkb3",
        ip_address = "10.0.0.38",
        target_node = "pve2"
      },
      {
        name = "swkb4",
        ip_address = "10.0.0.39",
        target_node = "pve1"
      },
      {
        name = "swkb5",
        ip_address = "10.0.0.40",
        target_node = "pve1"
      }
    ] 
  },
  {
    name = "Production"
    network_interface = "eth0",
    api_server_ip_address = "10.0.0.80"
    metallb_ip_address_range = "10.0.0.81-10.0.0.90"
    master_nodes_definition = [
      {
        name = "pmkb1",
        ip_address = "10.0.0.41",
        target_node = "pve2"
      },
      {
        name = "pmkb2",
        ip_address = "10.0.0.42",
        target_node = "pve2"
      },
      {
        name = "pmkb3",
        ip_address = "10.0.0.43",
        target_node = "pve1"
      }
    ],
    worker_nodes_definition = [
      {
        name = "pwkb1",
        ip_address = "10.0.0.44",
        target_node = "pve2"
      },
      {
        name = "pwkb2",
        ip_address = "10.0.0.45",
        target_node = "pve2"
      },
      {
        name = "pwkb3",
        ip_address = "10.0.0.46",
        target_node = "pve2"
      },
      {
        name = "pwkb4",
        ip_address = "10.0.0.47",
        target_node = "pve1"
      },
      {
        name = "pwkb5",
        ip_address = "10.0.0.48",
        target_node = "pve1"
      },
      {
        name = "pwkb6",
        ip_address = "10.0.0.49",
        target_node = "pve1"
      }
    ] 
  }
]
