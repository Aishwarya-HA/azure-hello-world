prefix         = "demo"
location       = "eastus"

address_space  = ["10.0.0.0/16"]
subnet_prefix  = "10.0.1.0/24"

vm_size = "Standard_DC1s_v3"

tags = {
  environment = "prod"
  project     = "azure-wrapper"
}
