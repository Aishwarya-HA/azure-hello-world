variable "subscription_id" {
  description = "Azure subscription ID where resources will be deployed."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "eastus"
}

variable "prefix" {
  description = "Prefix used for naming Azure resources."
  type        = string
  default     = "helloweb"
}

variable "admin_username" {
  description = "Admin username for SSH access."
  type        = string
  default     = "azureuser"
}

variable "admin_ssh_key" {
  description = "SSH public key for the admin user."
  type        = string
  sensitive   = true
}

variable "vm_size" {
  description = "VM size (e.g., Standard_B1s, Standard_B2s). Change to trigger wrapper resize."
  type        = string
  default     = "Standard_B1s"
}
