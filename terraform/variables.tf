
variable "subscription_id" {
  description = "Azure subscription ID where resources will be created."
  type        = string
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "East US 2"
}

variable "prefix" {
  description = "Name prefix for all resources."
  type        = string
  default     = "hello03"
}

variable "admin_username" {
  description = "Admin username for the VM (SSH user)."
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH PUBLIC key contents (output of: cat ~/.ssh/id_rsa.pub)."
  type        = string
}
