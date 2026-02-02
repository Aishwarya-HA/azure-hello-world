#############################################
# Root outputs.tf (safe references)
#############################################

output "resource_group_name" {
  description = "Resource group created by root."
  value       = azurerm_resource_group.rg.name
}

output "subnet_id" {
  description = "Subnet ID created by root."
  value       = azurerm_subnet.subnet.id
}

# From VM module (the module currently exposes vm_name, nic_id, private_ip)
output "vm_name" {
  description = "VM name created by the wrapper module."
  value       = try(module.web_vm.vm_name, null)
}

output "nic_id" {
  description = "NIC ID created by the wrapper module."
  value       = try(module.web_vm.nic_id, null)
}

output "private_ip" {
  description = "Private IP address of the VM NIC (from the module)."
  value       = try(module.web_vm.private_ip, null)
}

# If your module later exposes public_ip, these will automatically work.
output "public_ip" {
  description = "The public IP address of the VM (from the module)."
  value       = try(module.web_vm.public_ip, null)
}

output "web_url" {
  description = "The HTTP URL to access the deployed Hello World page."
  value       = try("http://${module.web_vm.public_ip}", null)
}
