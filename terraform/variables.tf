
variable "subscription_id" {
  type = string
}

variable "location" {
  type    = string
  default = "Central India"
}

variable "prefix" {
  type    = string
  default = "hello"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key" {
  type = string
}
