#############################################
# modules/vm_wrapper/main.tf (updated)
#############################################

# NIC
resource "azurerm_network_interface" "nic" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    # If you add a Public IP resource in this module, wire it here:
    # public_ip_address_id          = azurerm_public_ip.pip.id
  }

  tags = var.tags
}

# Linux VM
resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size

  network_interface_ids = [azurerm_network_interface.nic.id]

  # OS + Admin
  admin_username                      = var.admin_username
  disable_password_authentication     = true

  # Optional cloud-init
  # If cloud_init_file is provided, use it; else omit
  dynamic "custom_data" {
    for_each = var.cloud_init_file != "" ? [1] : []
    content {
      # NOTE: custom_data expects base64
      # azurerm provider: custom_data is a string, but docs recommend base64
      # Using filebase64 ensures correct encoding
    }
  }

  # Simpler form (no dynamic): if you always want cloud-init, uncomment:
  # custom_data = filebase64("${path.root}/cloud-init.yaml")

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

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  tags = var.tags

  # Optional: keep diffs quieter
  lifecycle {
    ignore_changes = [tags]
  }

  timeouts {
    create = "60m"
    delete = "60m"
  }
}

# If you decide to add a Public IP later, add:
# resource "azurerm_public_ip" "pip" { ... }
# and output it from outputs.tf
