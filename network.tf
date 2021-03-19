
resource "azurerm_virtual_network" "Test02" {
  name                = "${var.prefix}-network"
  location            = var.location
  resource_group_name = azurerm_resource_group.Test02.name
  address_space       = ["192.168.1.0/24"]
}

resource "azurerm_subnet" "Test02-internal-1" {
  name                 = "${var.prefix}-internal-1"
  resource_group_name  = azurerm_resource_group.Test02.name
  virtual_network_name = azurerm_virtual_network.Test02.name
  address_prefix       = "192.168.1.192/26"
}

resource "azurerm_network_security_group" "allow-ssh" {
    name                = "${var.prefix}-allow-ssh"
    location            = var.location
    resource_group_name = azurerm_resource_group.Test02.name

    security_rule {
        name                       = "RDP"
        priority                   = 310
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = var.ssh-source-address
        destination_address_prefix = "*"
    }
	security_rule {
        name                       = "Internet"
        priority                   = 320
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = var.ssh-source-address
        destination_address_prefix = "*"
    }
}

