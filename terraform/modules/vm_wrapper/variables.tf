variable "name" {
  type        = string
  description = "VM name"
}

variable "resource_group_name" {
  type        = string
  description = "Target resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the NIC"
}

variable "vm_size" {
  type        = string
  description = "VM size"
}

variable "admin_username" {
  type        = string
  description = "Admin username"
}

# ✅ Consistent with the usage inside the module
variable "ssh_public_key" {
  type        = string
  description = "SSH public key for VM admin access"
}

# Optional: pass a cloud-init file path from root (if exists)
variable "cloud_init_file" {
  type        = string
  description = "Path to cloud-init YAML file (optional)"
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
