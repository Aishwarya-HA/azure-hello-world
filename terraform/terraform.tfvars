prefix         = "demo"
location       = "eastus"

address_space  = ["10.0.0.0/16"]
subnet_prefix  = "10.0.1.0/24"

admin_username = "azureuser"
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCny7avEH9JI7LHCtsBk+cZ1pr5HBvzYbzO5jcJmNouWsILJX8CdMtl2jPNnbuNElk3Rex7BuXHwtxGx/eMASJiaAje4NlZhkVuF+eXnHVNhoq8ySEEg/e5UZgpsegFP7jQVRJEdrH3TZPlmw5ImLt/SvjyNkSf1hYtEDkjxQkdXsTYDG74c67yx7KT0zb0PdDXGxbybwhZ5puTIUGcSdxaRT7YSeEHPKCdDU8/2iVNeyir/lC8/4puNYeawyD0x0FB4o+lke3gip27NLSaT1Stk8Y+sBcolp1iEEh20n19FYP/Xw+xw5dwHkfgzYqPRJG+AovHVpYlbVvHeOh/KnZVRpHQOuU7IEeJCq8euTU+FETCdtqxjsvle9vrN7/aqL7dFrYLEmuDjI0L+74om6kr+z0rD6wYCalEA2cad+8yDUJq0vt1YHJR8/GEe92bnV7qGutFahN1wRX4LRNn/En6PJ/2xQEGAIpm1bj8OzbcRt6epDfSFSRA86SGQaWABfJDV+3N+u4sMGRivh6J5+yd0hxX+9SiBEiauqNtrwWRKP6q/F8I2Mz3Zfu2Yzf5eYIaBdYUq0UNHr5Yyq9J+03XubWU1elx4SOSVgmX3tfAn8p5IjBwuF1ORfEzwGt/K3xzWJyxElPgGYQJucEHokOpPsxClNlcxFbbJJgIE1PmxQ== aishwarya@azure-vm"

vm_size = "Standard_F2s_v2"

tags = {
  environment = "prod"
  project     = "azure-wrapper"
}
