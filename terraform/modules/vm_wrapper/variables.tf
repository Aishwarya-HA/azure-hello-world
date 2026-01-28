variable "name" {
  type        = string
  description = "Base name for VM resources"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group for resources"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID"
}

variable "public_ip_id" {
  type        = string
  description = "Public IP ID to attach to NIC"
  default     = null
}

variable "admin_username" {
  type        = string
}

variable "admin_ssh_key" {
  type        = string
  sensitive   = true
}

variable "vm_size" {
  type        = string
  description = "VM Size (Standard_B1s, Standard_B2s...)"
}

variable "custom_data_b64" {
  type        = string
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
