variable "name" {
  description = "Base name for VM and resources"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "public_ip_id" {
  description = "Public IP ID (optional)"
  type        = string
  default     = null
}

variable "admin_username" {
  description = "Admin username for SSH"
  type        = string
}

variable "admin_ssh_key" {
  description = "SSH public key for the admin user"
  type        = string
  sensitive   = true
}

variable "vm_size" {
  description = "VM size (e.g., Standard_B1s, Standard_B2s)"
  type        = string
  default     = "Standard_B1s"
}

variable "source_image_reference" {
  description = "Image to use for the VM"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

variable "custom_data_b64" {
  description = "Base64-encoded cloud-init user data (optional)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
