#############################################
# Terraform Azure – Root main.tf
# - Creates RG, VNet, Subnet, Public IP
# - Calls ./modules/vm_wrapper to create NIC + VM
# - Ensures admin_ssh_key is never empty
#############################################

# -----------------------------
# Locals
# -----------------------------
locals {
  # Prefer CI-provided key (TF_VAR_admin_ssh_key). If empty, use local file.
  default_pubkey_path     = pathexpand("~/.ssh/azure_vm.pub")
  effective_admin_ssh_key = trimspace(var.admin_ssh_key) != "" ? trimspace(var.admin_ssh_key) : (
    fileexists(local.default_pubkey_path) ? trimspace(file(local.default_pubkey_path)) : ""
  )

  # Base64-encode cloud-init (user-data)
  custom_data_b64 = base64encode(file("${path.module}/cloud-init.yaml"))

  # Naming
  rg_name   = "${var.prefix}-rg"
  vnet_name = "${var.prefix}-vnet"
  snet_name = "${var.prefix}-snet"
  pip_name  = "${var.prefix}-pip"
  vm_name   = "${var.prefix}-vm"
}

# -----------------------------
# Resource Group
# -----------------------------
resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location
  tags     = var.tags
}

# -----------------------------
# Virtual Network + Subnet
# -----------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

resource "azurerm_subnet" "subnet" {
  name                 = local.snet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# -----------------------------
# Public IP
# -----------------------------
resource "azurerm_public_ip" "pip" {
  name                = local.pip_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  allocation_method = "Static"
  sku               = "Standard"
  tags              = var.tags
}

# -----------------------------
# Safety check – ensure SSH key present
# (Prevents confusing apply-time errors)
# -----------------------------
locals {
  _validate_ssh_key = length(local.effective_admin_ssh_key) > 0 ? true : (
    throw("admin_ssh_key is empty. Provide TF_VAR_admin_ssh_key or ensure ~/.ssh/azure_vm.pub exists and is non-empty.")
  )
}

# -----------------------------
# VM + NIC via wrapper module
# -----------------------------
module "web_vm" {
  source = "./modules/vm_wrapper"

  # Names & placement
  name                = local.vm_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Networking
  subnet_id    = azurerm_subnet.subnet.id
  public_ip_id = azurerm_public_ip.pip.id

  # VM config
  vm_size        = var.vm_size
  admin_username = var.admin_username

  # SSH key – guaranteed non-empty by locals
  admin_ssh_key = local.effective_admin_ssh_key

  # cloud-init
  custom_data_b64 = local.custom_data_b64

  # Recommended: keep password auth disabled
  disable_password_authentication = true

  # Tags
  tags = var.tags
}

# -----------------------------
# Helpful notes:
# - To resize: change var.vm_size and apply.
# - Module includes lifecycle ignore on admin_ssh_key (as provided).
# -----------------------------
