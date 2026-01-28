#############################################
# Module variables.tf
#############################################

variable "name" {
  description = "Base name for VM resources"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for resources"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "public_ip_id" {
  description = "Public IP ID to attach to NIC"
  type        = string
  default     = null
}

variable "admin_username" {
  description = "Admin username"
  type        = string
}

# IMPORTANT: OpenSSH PUBLIC key string (contents of .pub file)
variable "admin_ssh_key" {
  description = "OpenSSH public key (the contents of your .pub file)."
  type        = string
  sensitive   = true

  validation {
    condition     = trim(var.admin_ssh_key) != ""
    error_message = "admin_ssh_key must be non-empty. Pass a valid public key string from the caller."
  }
}

variable "vm_size" {
  description = "VM Size (Standard_B1s, Standard_D2s_v5, ...)"
  type        = string
}

# Pass base64-encoded cloud-init from the root
variable "custom_data_b64" {
  description = "Base64-encoded cloud-init user data."
  type        = string
  default     = null
}

# Keep password auth disabled by default (secure)
variable "disable_password_authentication" {
  description = "Disable password authentication and require SSH keys."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources created by the module"
  type        = map(string)
  default     = {}
}
