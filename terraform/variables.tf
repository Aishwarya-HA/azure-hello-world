##############################################
# Root variables.tf  (updated)
##############################################

# ------------------------------
# Subscription / Region
# ------------------------------

variable "subscription_id" {
  description = "Azure subscription ID where resources will be deployed."
  type        = string
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  # Set your preferred default region
  default     = "centralindia"
}

# ------------------------------
# Naming
# ------------------------------

variable "prefix" {
  description = "Prefix used for naming Azure resources (lowercase letters, digits, hyphens)."
  type        = string
  # Keep your current default if you had one
  default     = "helloworld"

  validation {
    # 3–24 chars, lowercase letters/digits/hyphen only
    condition     = can(regex("^[a-z0-9-]{3,24}$", var.prefix))
    error_message = "Prefix must be 3–24 chars and contain only lowercase letters, digits, or hyphens."
  }
}

# ------------------------------
# Access
# ------------------------------

variable "admin_username" {
  description = "Admin username for the VM."
  type        = string
  default     = "azureuser"
}

# SSH PUBLIC key (contents of your .pub file)
variable "ssh_public_key" {
  description = "SSH public key used to log in."
  type        = string
  sensitive   = true
}

# ------------------------------
# Networking
# ------------------------------

variable "address_space" {
  description = "VNet address space."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_prefix" {
  description = "Subnet CIDR."
  type        = string
  default     = "10.0.1.0/24"
}

# ------------------------------
# Sizing
# ------------------------------

variable "vm_size" {
  description = "Azure VM size."
  type        = string
  # Keep the family you used in the repo; the workflow can override this during resize.
  default     = "Standard_D2ls_v5"
}

# ------------------------------
# Tags
# ------------------------------

variable "tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
  default     = {}
}

# ------------------------------
# VM Name (UPDATED)
# ------------------------------
# Make this OPTIONAL so plans don’t fail when not provided.
# Your main.tf will compute: <prefix>-vm when this is empty.
variable "vm_name" {
  description = "Optional explicit VM name; if empty, defaults to <prefix>-vm."
  type        = string
  default     = ""
}
