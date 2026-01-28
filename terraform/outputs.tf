output "public_ip" {
  description = "The public IP address of the VM."
  value       = azurerm_public_ip.pip.ip_address
}

output "web_url" {
  description = "The HTTP URL to access the deployed Hello World page."
  value       = "http://${azurerm_public_ip.pip.ip_address}"
}

# Optional: useful during debugging
output "vm_name" {
  value = module.web_vm.vm_name
}

output "private_ip" {
  value = module.web_vm.private_ip
}
