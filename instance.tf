# demo instance
resource "azurerm_virtual_machine" "Test02-instance" {
  name                  = "${var.prefix}-vm"
  location              = var.location
  resource_group_name   = azurerm_resource_group.Test02.name
  network_interface_ids = [azurerm_network_interface.Test02-instance.id]
  vm_size               = "Standard_A1_v2"

  # this is a demo instance, so we can delete all data on termination
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter-Core"
    version   = "latest"
  }

  storage_os_disk {
	name              = "${var.prefix}-OSdisk01"
    caching           = "ReadWrite"
	create_option     = "FromImage"
	managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "AZVMWin01"
    admin_username = "winusr"
    admin_password = "P@$$w0rd1234!"
  }
  os_profile_windows_config {
    #disable_password_authentication = false
    #ssh_keys {
    #  key_data = file("mykey.pub")
    #  path     = "/home/linuxusr/.ssh/authorized_keys"
    #}
  }
}

resource "azurerm_network_interface" "Test02-instance" {
  name                      = "${var.prefix}-instance1"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.Test02.name
  network_security_group_id = azurerm_network_security_group.allow-ssh.id

  ip_configuration {
    name                          = "instance1"
    subnet_id                     = azurerm_subnet.Test02-internal-1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.Test02-instance.id
  }
}

resource "azurerm_public_ip" "Test02-instance" {
    name                         = "${var.prefix}-public-ip"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.Test02.name
    allocation_method            = "Dynamic"
}
