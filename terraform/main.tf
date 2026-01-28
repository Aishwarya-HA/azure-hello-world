###############################################
# 1) Resource Group
###############################################
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

###############################################
# 2) Networking: VNet + Subnet
###############################################
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

###############################################
# 3) Public IP
###############################################
resource "azurerm_public_ip" "pip" {
  name                = "${var.prefix}-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

###############################################
# 4) Network Security Group (Allow SSH/HTTP)
###############################################
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate NSG to Subnet (simpler than per-NIC association)
resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

###############################################
# 5) Cloud-init (user data) using templatefile()
###############################################
locals {
  cloud_init = templatefile("${path.module}/cloud-init.yaml", {})
}

###############################################
# 6) VM Wrapper Module (creates NIC + VM)
###############################################
module "web_vm" {
  source = "./modules/vm_wrapper"

  name                = var.prefix
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  subnet_id    = azurerm_subnet.subnet.id
  public_ip_id = azurerm_public_ip.pip.id

  admin_username = var.admin_username
  admin_ssh_key  = var.admin_ssh_key

  # ---- Resize knob ----
  vm_size = var.vm_size

  # cloud-init must be base64 encoded
  custom_data_b64 = base64encode(local.cloud_init)

  tags = {
    app = "hello-world"
    env = "dev"
  }
}
