
# Azure subscription ID (passed via GitHub Secret: TF_VAR_SUBSCRIPTION_ID)
variable "subscription_id" {
  description = "Azure subscription ID where resources will be created."
  type        = string
}

# Region to deploy resources into
variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "East US 2"
}

# Prefix used to build resource names (e.g., <prefix>-rg, <prefix>-vm, etc.)
# Must start with a letter or digit and can contain only letters, digits, or hyphens.
variable "prefix" {
  description = "Name prefix for all resources. Example: hello03"
  type        = string
  default     = "hello03"

  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9-]*$", var.prefix))
    error_message = "prefix must start with an alphanumeric character and contain only letters, numbers, or hyphens (no spaces, no leading hyphen)."
  }
}

# Admin username for the Linux VM
variable "admin_username" {
  description = "Admin username for the VM (SSH user)."
  type        = string
  default     = "azureuser"
}

# SSH PUBLIC key used to access the VM (must be RSA and start with 'ssh-rsa')
variable "ssh_public_key" {
  description = "SSH PUBLIC key contents (output of: cat ~/.ssh/id_rsa.pub)."
  type        = string
}
``
