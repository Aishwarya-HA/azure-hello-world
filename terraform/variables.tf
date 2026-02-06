#############################################
# Root variables.tf (updated)
#############################################

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "eastus"
}

# Naming prefix
variable "prefix" {
  description = "Prefix used for naming Azure resources (lowercase letters, digits, hyphens)."
  type        = string
  default     = "helloworld"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,24}$", var.prefix))
    error_message = "Prefix must be 3–24 chars and contain only lowercase letters, digits, or hyphens."
  }
}

# ---------- Network ----------
variable "address_space" {
  description = "VNet address spaces."
  type        = list(string)   # e.g., ["10.0.0.0/16"]
}

variable "subnet_prefix" {
  description = "Subnet CIDR prefix."
  type        = string         # e.g., "10.0.1.0/24"
}

# ---------- Admin + SSH ----------
variable "admin_username" {
  description = "Admin username for the VM."
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  type        = string
  sensitive   = true
  description = "SSH public key for VM admin access"
  #default     = ""
}

# ---------- VM size ----------
variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_DC1s_v3"
}

# ---------- Tags ----------
variable "tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
  default     = {}
}
