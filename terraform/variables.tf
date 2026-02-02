#############################################
# Root variables.tf (updated)
#############################################

# Subscription / Region
# Note: If you're using OIDC in GitHub Actions and exporting ARM_* env vars,
# you don't need to pass subscription_id via Terraform variables. It's fine to keep
# this if you reference it anywhere; otherwise you can remove it.
variable "subscription_id" {
  description = "Azure subscription ID where resources will be deployed."
  type        = string
}

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

# ---------- NEW: Network variables required by main.tf ----------
variable "address_space" {
  description = "VNet address spaces."
  type        = list(string)
  # Example: ["10.0.0.0/16"]
}

variable "subnet_prefix" {
  description = "Subnet CIDR prefix."
  type        = string
  # Example: "10.0.1.0/24"
}

# Admin username
variable "admin_username" {
  description = "Admin username for the VM."
  type        = string
  default     = "azureuser"
}

# SSH PUBLIC key (contents of your .pub file)
variable "ssh_public_key" {
  type        = string
  description = "SSH public key for VM admin access"
}

# VM sizing (resize knob)
variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_DC1s_v3"
}

# (Optional) Tags
variable "tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
  default     = {}
}
