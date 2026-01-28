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

# The NIC is created inside the module, so we associate the NSG to the **subnet**
# (this is simpler and applies to all NICs in this subnet). If you prefer per‑NIC
# association, we can switch to NIC‑level association — just tell me.
resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

###############################################
# 5) Cloud-init (user data)
###############################################
# Renders your existing cloud-init.yaml from the repo
data "template_file" "cloud_init" {
  template = file("${path.module}/cloud-init.yaml")
}

###############################################
# 6) VM Wrapper Module (NIC + VM inside)
###############################################
module "web_vm" {
  source = "./modules/vm_wrapper"

  # Naming & placement
  name                = var.prefix
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Networking (module builds the NIC and attaches the PIP)
  subnet_id    = azurerm_subnet.subnet.id
  public_ip_id = azurerm_public_ip.pip.id

  # Access
  admin_username = var.admin_username
  admin_ssh_key  = var.admin_ssh_key

  # ---- Resize knob ----
  vm_size = var.vm_size  # Change this to resize safely via wrapper

  # Cloud-init (must be base64 for azurerm_linux_virtual_machine)
  custom_data_b64 = base64encode(data.template_file.cloud_init.rendered)

  # Optional tags
  tags = {
    app = "hello-world"
    env = "dev"
  }
}

###############################################
# 7) (Optional) Output IP here or in outputs.tf
###############################################
# Many teams keep outputs in outputs.tf; if you prefer, keep only there.
# Shown here for clarity; you can delete this block if you already have the same in outputs.tf.
output "public_ip" {
  description = "The public IP address of the VM."
  value       = azurerm_public_ip.pip.ip_address
}

output "web_url" {
  description = "HTTP URL to access the Hello World page."
  value       = "http://${azurerm_public_ip.pip.ip_address}"
}
