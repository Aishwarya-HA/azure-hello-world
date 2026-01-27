
############################################
# Subscription ID (required)
############################################
variable "subscription_id" {
  description = "Azure Subscription ID where resources will be deployed."
  type        = string
}

############################################
# Region
############################################
variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "centralindia"  # Safe region with good capacity
}

############################################
# Resource Name Prefix
############################################
variable "prefix" {
  description = "Prefix used for naming Azure resources (e.g., aish01 → aish01-rg, aish01-vm)."
  type        = string
  default     = "hello04"

  # Must start with a letter or number; no spaces; hyphens allowed
  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9-]*$", var.prefix))
    error_message = "Prefix must start with an alphanumeric character and contain only letters, digits, or hyphens."
  }
}

############################################
# Admin Username
############################################
variable "admin_username" {
  description = "Admin username for SSH access to the VM."
  type        = string
  default     = "azureuser"
}

############################################
# SSH Public Key (required)
############################################
variable "ssh_public_key" {
  description = "SSH public key for authentication (contents of ~/.ssh/id_rsa.pub or ~/.ssh/id_ed25519.pub)."
  type        = string
}

############################################
# VM Size
############################################
variable "vm_size" {
  description = "Size of the Azure Linux VM."
  type        = string
  default     = Standard_D2_v2

}
 
  # You can override via TF_VAR_vm_size if needed
