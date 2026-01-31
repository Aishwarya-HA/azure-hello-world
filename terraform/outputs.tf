##############################################
# Root outputs.tf (UPDATED)
##############################################

# -------------------------------------------
# Infrastructure / workflow helper outputs
# -------------------------------------------

output "resource_group_name" {
  description = "Resource Group used by this deployment."
  value       = azurerm_resource_group.rg.name
}

output "location" {
  description = "Azure region where resources are deployed."
  value       = azurerm_resource_group.rg.location
}

# -------------------------------------------
# VM information (from wrapper module)
# -------------------------------------------

# IMPORTANT:
# Your module block is named `web_vm`
# If your module name is different, update `module.web_vm` accordingly

output "vm_name" {
  description = "Name of the Linux VM created by the wrapper module."
  value       = module.web_vm.vm_name
}

output "private_ip" {
  description = "Private IP address of the VM NIC."
  value       = module.web_vm.private_ip
}

# -------------------------------------------
# Public access
# -------------------------------------------

output "public_ip" {
  description = "Public IP address of the VM."
  value       = azurerm_public_ip.pip.ip_address
}

output "web_url" {
  description = "HTTP URL to access the VM (if a web service is running)."
  value       = "http://${azurerm_public_ip.pip.ip_address}"
}
