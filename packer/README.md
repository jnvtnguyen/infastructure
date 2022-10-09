## Packer for Creation of Template VM's for Cloning

#### Create a Credentials File
```
proxmox_api_url = "https://0.0.0.0:8006/api2/json"
proxmox_api_token_id = "packer@pve!packer"
proxmox_api_token_secret = "your-api-token-secret"
```

#### Create a Template VM
```
packer build --var-file='credentials.pkr.secret.hcl' ./ubuntu-server-jammy.pkr.hcl
```
