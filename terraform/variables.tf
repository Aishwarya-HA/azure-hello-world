################################
# Subscription / Region
################################
variable "subscription_id" {
  description = "Azure subscription ID where resources will be deployed."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "eastus"
}

################################
# Naming
################################
variable "prefix" {
  description = "Prefix used for naming Azure resources."
  type        = string
  default     = "helloweb"
  validation {
    condition     = can(regex("^[a-z0-9-]{3,24}$", var.prefix))
    error_message = "prefix must be 3-24 chars with lowercase letters, digits or hyphens."
  }
}

################################
# Admin access
################################
variable "admin_username" {
  description = "Admin username for SSH access to the VM."
  type        = string
  default     = "azureuser"
}

variable "admin_ssh_key" {
  description = "SSH public key for authentication (contents of ~/.ssh/id_rsa.pub)."
  type        = string
  sensitive   = true
}

################################
# VM size (resize knob)
################################
variable "vm_size" {
  description = "Size of the Azure Linux VM."
  type        = string
  default     = "Standard_B1s"
}
``
