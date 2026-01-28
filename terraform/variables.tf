################################
# Subscription / Region
################################
variable "subscription_id" {
  description = "Azure subscription ID where resources will be deployed."
  type        = string
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "eastus"
}

################################
# Naming
################################
variable "prefix" {
  description = "Prefix used for naming Azure resources (lowercase letters, digits, hyphens)."
  type        = string
  default     = "helloweb"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,24}$", var.prefix))
    error_message = "prefix must be 3–24 chars and contain only lowercase letters, digits, or hyphens."
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
  description = "SSH PUBLIC key for the admin user (contents of your *.pub file)."
  type        = string
  sensitive   = true
}

################################
# VM sizing (resize knob)
################################
variable "vm_size" {
  description = "Azure VM size (e.g., Standard_B1s, Standard_B2s). Change this to resize the VM."
  type        = string
  default     = "Standard_B1s"
}

################################
# (Optional) Tags
################################
variable "tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
  default     = {}
}
