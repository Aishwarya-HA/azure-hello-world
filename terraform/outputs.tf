output "public_ip" {
  description = "The public IP address of the VM."
  value       = azurerm_public_ip.pip.ip_address
}

output "web_url" {
  description = "The HTTP URL to access the deployed Hello World page."
  value       = "http://${azurerm_public_ip.pip.ip_address}"
}

# Optional: helpful for debugging/visibility
output "vm_name" {
  description = "VM name created by the wrapper"
  value       = module.web_vm.vm_name
}

output "private_ip" {
  description = "Private IP address of the VM NIC"
  value       = module.web_vm.private_ip
}
