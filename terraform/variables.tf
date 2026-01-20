
// terraform/variables.tf

// Your Azure subscription ID (passed from GitHub Secret: TF_VAR_SUBSCRIPTION_ID)
variable "subscription_id" {
  description = "Azure subscription ID where resources will be created."
  type        = string
}

// Region to deploy resources into (we chose East US to avoid SKU capacity issues)
variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "East US"
}

// Prefix for resource names (becomes hello-rg, hello-vnet, etc.)
variable "prefix" {
  description = "Name prefix for all resources."
  type        = string
  default     = "hello"
}

// Admin username for the Linux VM
variable "admin_username" {
  description = "Admin username for the VM (SSH user)."
  type        = string
  default     = "azureuser"
}

// SSH public key used to access the VM (must be RSA: line starting with 'ssh-rsa')
variable "ssh_public_key" {
  description = "SSH PUBLIC key contents (e.g., output of: cat ~/.ssh/id_rsa.pub)."
  type        = string
}
``
