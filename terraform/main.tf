##############################################
# Root: main.tf (updated with computed vm_name)
##############################################

# ------------------------------
# Resource Group
# ------------------------------
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location

  tags = var.tags
}

# ------------------------------
# Networking
# ------------------------------

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = var.address_space

  tags = var.tags
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_prefix]
}

# Network Security Group (SSH)
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# Associate NSG to Subnet
resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# (Optional) Small propagation delay if you previously saw NIC/NSG timing issues
resource "time_sleep" "network_delay" {
  depends_on = [
    azurerm_subnet_network_security_group_association.subnet_nsg
  ]
  create_duration = "10s"
}

# ------------------------------
# Public IP (Standard Static)
# ------------------------------
resource "azurerm_public_ip" "pip" {
  name                = "${var.prefix}-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  allocation_method = "Static"
  sku               = "Standard"

  tags = var.tags
}

# ------------------------------
# Compute the VM name once
# If var.vm_name is empty, default to "<prefix>-vm"
# ------------------------------
locals {
  computed_vm_name = length(var.vm_name) > 0 ? var.vm_name : "${var.prefix}-vm"
}

# ------------------------------
# VM Wrapper Module
# ------------------------------
module "web_vm" {
  source = "./modules/vm_wrapper"

  # Derived VM name (fixes "No value for required variable vm_name")
  vm_name             = local.computed_vm_name

  # Placement
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Networking
  subnet_id    = azurerm_subnet.subnet.id
  public_ip_id = azurerm_public_ip.pip.id  # module attaches this PIP to the NIC

  # Access + Size
  admin_username = var.admin_username
  ssh_public_key = var.ssh_public_key
  vm_size        = var.vm_size

  # Tags
  tags = var.tags

  # NOTE: Your module already has:
  #   - disable_password_authentication = true (default)
  #   - lifecycle ignore blocks (optional) inside the module, if any
}

# ------------------------------
# (Optional) Outputs are defined in terraform/outputs.tf
# Ensure it exports resource_group_name, location, vm_name, public_ip, etc.
# ------------------------------
