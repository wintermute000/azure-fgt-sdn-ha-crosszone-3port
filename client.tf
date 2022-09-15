
// Setup for Test Client1
resource "azurerm_network_interface" "client1_nic" {
  name                = "${var.client1name}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.private2subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = local.common_tags
}


resource "azurerm_linux_virtual_machine" "client1" {
  name                            = var.client1name
  resource_group_name             = azurerm_resource_group.myterraformgroup.name
  location                        = var.location
  size                            = var.client_size
  admin_username                  = var.adminusername
  admin_password                  = var.adminpassword
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.client1_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  tags = local.common_tags
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "client_shutdown_schedule" {
  virtual_machine_id = azurerm_linux_virtual_machine.client1.id
  location           = azurerm_resource_group.myterraformgroup.location
  enabled            = true

  daily_recurrence_time = "2359"
  timezone              = "AUS Eastern Standard Time"


  notification_settings {
    enabled = false

  }
}

// Setup for Test Client2
resource "azurerm_network_interface" "client2_nic" {
  name                = "${var.client2name}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.private3subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = local.common_tags
}

resource "azurerm_linux_virtual_machine" "client2" {
  name                            = var.client2name
  resource_group_name             = azurerm_resource_group.myterraformgroup.name
  location                        = var.location
  size                            = var.client_size
  admin_username                  = var.adminusername
  admin_password                  = var.adminpassword
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.client2_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  tags = local.common_tags
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "client2_shutdown_schedule" {
  virtual_machine_id = azurerm_linux_virtual_machine.client2.id
  location           = azurerm_resource_group.myterraformgroup.location
  enabled            = true

  daily_recurrence_time = "2359"
  timezone              = "AUS Eastern Standard Time"


  notification_settings {
    enabled = false

  }
}