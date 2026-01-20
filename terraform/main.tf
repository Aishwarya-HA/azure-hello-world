
########################################
# Tags & safe prefix (sanitized)
########################################
locals {
  # User/Repo tags
  tags = {
    project = "hello-world"
    owner   = "aishwarya"
  }

  # Sanitize the incoming prefix so all names begin with a letter/number
  # 1) Trim whitespace; 2) Strip any leading non-alphanumeric characters
  _prefix_trimmed = trimspace(var.prefix)
  safe_prefix     = regexreplace(local._prefix_trimmed, "^[^0-9A-Za-z]+", "")
}

########################################
# Resource Group (with guard on safe_prefix)
########################################
resource "azurerm_resource_group" "rg" {
  name     = "${local.safe_prefix}-rg"
  location = var.location
  tags     = local.tags

  # Fail fast if the computed safe_prefix is still invalid or empty
  lifecycle {
    precondition {
      condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9-]*$", local.safe_prefix))
      error_message = "Computed safe_prefix is invalid or empty. Check TF_VAR_PREFIX and variables.tf."
    }
  }
}

########################################
# Network: VNet + Subnet
########################################
resource "azurerm_virtual_network" "vnet" {
  name                = "${local.safe_prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags
}

resource "azurerm_subnet" "subnet" {
  name                 = "${local.safe_prefix}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

########################################
# NSG (Allow HTTP 80 & SSH 22)
########################################
resource "azurerm_network_security_group" "nsg" {
  name                = "${local.safe_prefix}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # TIP: Restrict SSH to your IP or use Bastion in production
  security_rule {
    name                       = "AllowSSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

########################################
# Public IP
########################################
resource "azurerm_public_ip" "pip" {
  name                = "${local.safe_prefix}-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

# Short settle to avoid provider read-after-write flake on PIP
resource "null_resource" "pip_settle" {
  depends_on = [azurerm_public_ip.pip]

  provisioner "local-exec" {
    command = "sleep 10"
  }
}

########################################
# NIC + NSG Association
########################################
resource "azurerm_network_interface" "nic" {
  name                = "${local.safe_prefix}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags

  # Ensure NIC config runs after the public IP has fully propagated
  depends_on = [null_resource.pip_settle]

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

########################################
# Linux VM (Ubuntu 22.04 LTS) + cloud-init
########################################
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${local.safe_prefix}-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  # Widely available size. If capacity blocks in your chosen region, try "Standard_A2_v2".
  size           = "Standard_B2s"
  admin_username = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  # SSH only (no passwords)
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    name                 = "${local.safe_prefix}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  # Ensure terraform/cloud-init.yaml exists next to this file
  custom_data = base64encode(file("${path.module}/cloud-init.yaml"))

  tags = local.tags
}
