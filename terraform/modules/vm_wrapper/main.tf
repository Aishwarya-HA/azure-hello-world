# Network interface (created inside wrapper)
resource "azurerm_network_interface" "nic" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_id
  }

  tags = var.tags
}

# The VM itself
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.name}-vm"
  location            = var.location
  resource_group_name = var.resource_group_name

  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_key
  }

  os_disk {
    name                 = "${var.name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.source_image_reference.publisher
    offer     = var.source_image_reference.offer
    sku       = var.source_image_reference.sku
    version   = var.source_image_reference.version
  }

  # Optional: pass cloud-init (custom_data must be base64)
  dynamic "custom_data" {
    for_each = var.custom_data_b64 == null ? [] : [1]
    content  = var.custom_data_b64
  }

  tags = var.tags
}

# ----------------- Resize orchestration (wrapper behavior) -----------------
# In-place resize may fail; safer to deallocate → resize → start via az CLI.
# We trigger when vm_size changes.

locals {
  resize_trigger = md5("${azurerm_linux_virtual_machine.vm.id}-${var.vm_size}")
}

# 1) Deallocate
resource "null_resource" "deallocate_for_resize" {
  triggers = { t = local.resize_trigger }

  provisioner "local-exec" {
    command = <<EOT
      set -euo pipefail
      echo "Deallocating VM ${azurerm_linux_virtual_machine.vm.name} before resize..."
      az vm deallocate \
        --resource-group ${var.resource_group_name} \
        --name ${azurerm_linux_virtual_machine.vm.name} \
        --only-show-errors
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}

# 2) Resize
resource "null_resource" "apply_resize" {
  triggers   = { t = local.resize_trigger }
  depends_on = [null_resource.deallocate_for_resize]

  provisioner "local-exec" {
    command = <<EOT
      set -euo pipefail
      echo "Resizing VM ${azurerm_linux_virtual_machine.vm.name} to ${var.vm_size}..."
      az vm resize \
        --resource-group ${var.resource_group_name} \
        --name ${azurerm_linux_virtual_machine.vm.name} \
        --size ${var.vm_size} \
        --only-show-errors
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}

# 3) Start
resource "null_resource" "start_after_resize" {
  triggers   = { t = local.resize_trigger }
  depends_on = [null_resource.apply_resize]

  provisioner "local-exec" {
    command = <<EOT
      set -euo pipefail
      echo "Starting VM ${azurerm_linux_virtual_machine.vm.name} after resize..."
      az vm start \
        --resource-group ${var.resource_group_name} \
        --name ${azurerm_linux_virtual_machine.vm.name} \
        --only-show-errors
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}
