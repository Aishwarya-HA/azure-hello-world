#############################################
# Workaround: control-plane propagation delay
# (prevents "Root object was present, but now absent" on NIC)
#############################################
resource "time_sleep" "network_delay" {
  # give Azure a moment after VNet/Subnet/PIP are created in root
  create_duration = "8s"
}

#############################################
# NIC
#############################################
resource "azurerm_network_interface" "nic" {
  depends_on = [time_sleep.network_delay]

  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_id
  }

  tags = var.tags

  # Optional: ignore short-lived diffs while Azure populates fields
  lifecycle {
    ignore_changes = [
      ip_configuration[0].private_ip_address
    ]
  }
}

#############################################
# Linux VM
#############################################
resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size

  # ... (image, os_disk, NIC, etc.)

  admin_username = var.admin_username

  # ✅ Use ssh_public_key from module inputs
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  tags = var.tags
}

  os_disk {
    name                 = "${var.name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Ubuntu 22.04 LTS (Jammy)
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # cloud-init: azurerm expects base64-encoded string
  custom_data = var.custom_data_b64

  tags = var.tags

  # Prevent noisy diffs on admin_ssh_key if you only change vm_size
  lifecycle {
    ignore_changes = [
      admin_ssh_key
    ]
  }

  # Sometimes creation is slow due to control-plane delays
  timeouts {
    create = "30m"
    update = "30m"
  }
}

#############################################
# (Module outputs are in outputs.tf)
#############################################
