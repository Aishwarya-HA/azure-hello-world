#############################################
# Root outputs.tf (safe references)
#############################################

# Resource group and subnet always exist in root
output "resource_group_name" {
  description = "Resource group created by root."
  value       = azurerm_resource_group.rg.name
}

output "subnet_id" {
  description = "Subnet ID created by root."
  value       = azurerm_subnet.subnet.id
}

# --- From VM module (use try(...) so validate doesn't fail if output is absent) ---

# Public IP of VM (assumes module exposes `public_ip`)
# If your module uses a different name (e.g., `public_ip_address`), change below accordingly.
output "public_ip" {
  description = "The public IP address of the VM (from the module)."
  value       = try(module.web_vm.public_ip, null)
}

# Convenience URL (only if public_ip exists)
output "web_url" {
  description = "The HTTP URL to access the deployed Hello World page."
  value       = try("http://${module.web_vm.public_ip}", null)
}

# Helpful visibility outputs (these already reference the module in your file)
output "vm_name" {
  description = "VM name created by the wrapper module."
  value       = try(module.web_vm.vm_name, null)
}

output "private_ip" {
  description = "Private IP address of the VM NIC (from the module)."
  value       = try(module.web_vm.private_ip, null)
}
