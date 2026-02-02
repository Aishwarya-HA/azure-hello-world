############################################################
# Root module: resource group + network + VM via module
# Notes:
# - SSH key is passed to the module as `admin_ssh_key = var.ssh_public_key`
# - No locals inside the module call
############################################################

# ---------- Optional naming helpers ----------
locals {
  # A consistent prefix and common names
  rg_name     = "${var.prefix}-rg"
  vnet_name   = "${var.prefix}-vnet"
  subnet_name = "${var.prefix}-subnet"
  nsg_name    = "${var.prefix}-nsg"
  vm_name     = "${var.prefix}-vm"
}

# ---------- Resource Group ----------
resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location

  tags = merge(
    {
      "managed-by" = "terraform"
    },
    var.tags
  )
}

# ---------- Virtual Network ----------
resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.address_space

  tags = var.tags
}

# ---------- Subnet ----------
resource "azurerm_subnet" "subnet" {
  name                 = local.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_prefix]
}

# ---------- NSG for SSH (allow inbound 22) ----------
resource "azurerm_network_security_group" "ssh_nsg" {
  name                = local.nsg_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1000
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

# ---------- Associate NSG to Subnet ----------
resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.ssh_nsg.id
}

# ---------- VM via module ----------
# Your module should accept these inputs. If your module has different
# variable names, tell me and I’ll adjust them exactly.
module "web_vm" {
  source = "./modules/vm_wrapper"

  # Core
  name                = local.vm_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.subnet.id

  # VM settings
  vm_size        = var.vm_size
  admin_username = var.admin_username

  # ✅ Pass the key with the name the module actually uses
  ssh_public_key = var.ssh_public_key

  # Tags
  tags = var.tags
}

# ---------- (Optional) Outputs ----------
# Uncomment/adjust based on what your module exposes
# output "vm_id" {
#   value = module.web_vm.vm_id
# }
# output "vm_public_ip" {
#   value = module.web_vm.public_ip
# }
