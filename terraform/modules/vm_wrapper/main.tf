#############################################
# modules/vm_wrapper/main.tf (fixed)
#############################################

# Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    # If you later add a Public IP in this module, wire it here:
    # public_ip_address_id = azurerm_public_ip.pip.id
  }

  # tags must be at NIC resource level
  tags = var.tags
}

# Linux VM
resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size

  # Attach NIC
  network_interface_ids = [azurerm_network_interface.nic.id]

  # OS + Admin
  admin_username                  = var.admin_username
  disable_password_authentication = true

  # ✅ Correct: 'custom_data' is an ARGUMENT, not a block
  # If a file path is provided, use its base64; else omit with null.
  custom_data = var.cloud_init_file != "" ? filebase64(var.cloud_init_file) : null

  os_disk {
    name                 = "${var.name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Ubuntu 22.04 LTS Gen2
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # SSH key
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  # Top-level only
  tags = var.tags

  lifecycle {
    ignore_changes = [tags]
  }

  timeouts {
    create = "60m"
    delete = "60m"
  }
}
