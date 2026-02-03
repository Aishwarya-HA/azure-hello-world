prefix         = "demo"
location       = "eastus"

address_space  = ["10.0.0.0/16"]
subnet_prefix  = "10.0.1.0/24"

admin_username = "azureuser"
ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILHvThbfk+GZpMhqtjXORfF7MrDe2lMXRV45mAccxeAo aishwarya@azure-vm"

vm_size = "Standard_DC1s_v3"

tags = {
  environment = "prod"
  project     = "azure-wrapper"
}
