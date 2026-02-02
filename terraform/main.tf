#############################################
# Root main.tf
# - RG → settle → VNet → settle → Subnet (timeouts)
# - Public IP (timeouts)
# - Passes values to ./modules/vm_wrapper (NIC + VM)
# - SSH key and cloud-init handled safely
#############################################

#############################################
# Locals: SSH key, cloud-init, names
#############################################
locals {
  # Prefer CI-provided key via TF_VAR_admin_ssh_key. If empty, try a local file.
  # Update this path if your .pub differs.
  default_pubkey_path = pathexpand("~/.ssh/azure_vm_rsa.pub")

  effective_admin_ssh_key = trimspace(var.admin_ssh_key) != "" ? trimspace(var.admin_ssh_key) : (
    fileexists(local.default_pubkey_path) ? trimspace(file(local.default_pubkey_path)) : ""
  )

  # ✅ FIXED: keep the entire conditional on one line
  custom_data_b64 = fileexists("${path.module}/cloud-init.yaml") ? base64encode(file("${path.module}/cloud-init.yaml")) : null

  # Resource names from prefix
  rg_name   = "${var.prefix}-rg"
  vnet_name = "${var.prefix}-vnet"
  snet_name = "${var.prefix}-snet"
  pip_name  = "${var.prefix}-pip"
  vm_name   = "${var.prefix}-vm"
}

#############################################
# Resource Group
#############################################
resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location
  tags     = var.tags
}

#############################################
# Settle after RG (helps PIP/VNet reads)
#############################################
resource "time_sleep" "rg_settle" {
  depends_on      = [azurerm_resource_group.rg]
  create_duration = "12s"
}

#############################################
# Virtual Network
#############################################
resource "azurerm_virtual_network" "vnet" {
  depends_on          = [time_sleep.rg_settle]

  name                = local.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

#############################################
# Extra settle after VNet (avoid 404 on Subnet read)
#############################################
resource "time_sleep" "vnet_settle" {
  depends_on      = [azurerm_virtual_network.vnet]
  create_duration = "30s" # bump to 40s if your tenant/region is still flaky
}

#############################################
# Subnet (explicitly depends on VNet + settle)
#############################################
resource "azurerm_subnet" "subnet" {
  depends_on = [
    azurerm_virtual_network.vnet,
    time_sleep.vnet_settle
  ]

  name                 = local.snet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  timeouts {
    create = "30m"
    read   = "15m"
    delete = "30m"
  }
}

#############################################
# Public IP (Standard, Static) with timeouts
#############################################
resource "azurerm_public_ip" "pip" {
  depends_on          = [time_sleep.rg_settle]

  name                = local.pip_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  allocation_method = "Static"
  sku               = "Standard"
  ip_version        = "IPv4"

  timeouts {
    create = "30m"
    update = "30m"
  }

  tags = var.tags
}

#############################################
# VM + NIC via wrapper module
#############################################
module "web_vm" {
  source = "./modules/vm_wrapper"

  # Names & placement
  name                = local.vm_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Networking (from resources above)
  subnet_id    = azurerm_subnet.subnet.id
  public_ip_id = azurerm_public_ip.pip.id

  # VM config
  vm_size        = var.vm_size
  admin_username = var.admin_username

  # SSH key — required when password auth is disabled
  locals {
  effective_admin_ssh_key = var.ssh_public_key
}

  # cloud-init: base64 string or null
  custom_data_b64 = local.custom_data_b64

  # Keep password auth disabled (secure)
  disable_password_authentication = true

  tags = var.tags
}
####
