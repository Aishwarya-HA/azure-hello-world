
output "public_ip" {
  value = azurerm_public_ip.pip.ip_address
}

output "web_url" {
  value = "http://${azurerm_public_ip.pip.ip_address}"
}
