resource "azurerm_image" "custom" {
  count               = var.custom ? 1 : 0
  name                = var.custom_image_name
  resource_group_name = var.custom_image_resource_group_name
  location            = var.location
  os_disk {
    os_type  = "Linux"
    os_state = "Generalized"
    blob_uri = var.customuri
    size_gb  = 2
  }
}

# resource "azurerm_virtual_machine" "customactivefgtvm" {
#   count                        = var.custom ? 1 : 0
#   name                         = "customactivefgt"
#   location                     = var.location
#   resource_group_name          = azurerm_resource_group.myterraformgroup.name
#   network_interface_ids        = [azurerm_network_interface.activeport1.id, azurerm_network_interface.activeport2.id, azurerm_network_interface.activeport3.id]
#   primary_network_interface_id = azurerm_network_interface.activeport1.id
#   vm_size                      = var.size
#   zones                        = [var.zone1]

#   delete_os_disk_on_termination    = true
#   delete_data_disks_on_termination = true

#   storage_image_reference {
#     id = var.custom ? element(azurerm_image.custom.*.id, 0) : null
#   }

#   storage_os_disk {
#     name              = "osDisk"
#     caching           = "ReadWrite"
#     managed_disk_type = "Standard_LRS"
#     create_option     = "FromImage"
#   }

#   # Log data disks
#   storage_data_disk {
#     name              = "activedatadisk"
#     managed_disk_type = "Standard_LRS"
#     create_option     = "Empty"
#     lun               = 0
#     disk_size_gb      = "30"
#   }

#   os_profile {
#     computer_name  = "customactivefgt"
#     admin_username = var.adminusername
#     admin_password = var.adminpassword
#     custom_data = templatefile("${var.bootstrap-active}", {
#       type            = var.license_type
#       license_file    = var.license
#       port1_ip        = var.activeport1
#       port1_mask      = var.activeport1mask
#       port2_ip        = var.activeport2
#       port2_mask      = var.activeport2mask
#       port3_ip        = var.activeport3
#       port3_mask      = var.activeport3mask
#       passive_peerip  = var.passiveport1
#       mgmt_gateway_ip = var.port1gateway
#       defaultgwy      = var.port2gateway
#       tenant          = var.tenant_id
#       subscription    = var.subscription_id
#       clientid        = var.client_id
#       clientsecret    = var.client_certificate_path
#       adminsport      = var.adminsport
#       rsg             = azurerm_resource_group.myterraformgroup.name
#       clusterip       = azurerm_public_ip.ClusterPublicIP.name
#       routename       = azurerm_route_table.internal.name
#     })
#   }

#   os_profile_linux_config {
#     disable_password_authentication = false
#   }

#   boot_diagnostics {
#     enabled     = true
#     storage_uri = azurerm_storage_account.fgtstorageaccount.primary_blob_endpoint
#   }

#   tags = local.common_tags
# }



resource "azurerm_virtual_machine" "activefgtvm" {
  count                            = var.custom ? 0 : 1
  name                             = var.activename
  location                         = var.location
  resource_group_name              = azurerm_resource_group.myterraformgroup.name
  network_interface_ids            = [azurerm_network_interface.activeport1.id, azurerm_network_interface.activeport2.id, azurerm_network_interface.activeport3.id]
  primary_network_interface_id     = azurerm_network_interface.activeport1.id
  vm_size                          = var.size
  zones                            = var.availability_zone ? [var.zone1] : null
  availability_set_id              = var.availability_zone ? null : azurerm_availability_set.fgt_av_set[0].id
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = var.custom ? null : var.publisher
    offer     = var.custom ? null : var.fgtoffer
    sku       = var.license_type == "byol" ? var.fgtsku["byol"] : var.fgtsku["payg"]
    version   = var.custom ? null : var.fgtversion
    id        = var.custom ? element(azurerm_image.custom.*.id, 0) : null
  }

  plan {
    name      = var.license_type == "byol" ? var.fgtsku["byol"] : var.fgtsku["payg"]
    publisher = var.publisher
    product   = var.fgtoffer
  }


  storage_os_disk {
    name              = "${var.activename}-osDisk"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    create_option     = "FromImage"
  }

  # Log data disks
  storage_data_disk {
    name              = "${var.activename}-activedatadisk"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "30"
  }

  os_profile {
    computer_name  = var.activename
    admin_username = var.adminusername
    admin_password = var.adminpassword
    custom_data = templatefile("${var.bootstrap-active}", {
      type            = var.license_type
      license_file    = var.fgtlicense != "" ? "./licenses/${var.fgtlicense}" : ""
      activename      = var.activename
      port1_ip        = var.activeport1
      port1_mask      = var.activeport1mask
      port2_ip        = var.activeport2
      port2_mask      = var.activeport2mask
      port3_ip        = var.activeport3
      port3_mask      = var.activeport3mask
      passive_peerip  = var.passiveport1
      mgmt_gateway_ip = var.port1gateway
      defaultgwy      = var.port2gateway
      port3gateway    = var.port3gateway
      tenant          = var.tenant_id
      subscription    = var.subscription_id
      # clientid        = var.client_id
      # clientsecret    = var.client_certificate_path
      adminsport     = var.adminsport
      sshport        = var.sshport
      vnetcidr       = var.vnetcidr
      port2name      = "${var.activename}-port2"
      rsg            = azurerm_resource_group.myterraformgroup.name
      clusterip      = azurerm_public_ip.ClusterPublicIP.name
      routetablename = azurerm_route_table.private_rt.name
      fgtflextoken   = var.fgtflextoken
    })
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.fgtstorageaccount.primary_blob_endpoint
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags

  depends_on = [
    azurerm_role_definition.sdn_connector_ha_role,
  ]

}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "activefgtvm_shutdown_schedule" {
  virtual_machine_id = azurerm_virtual_machine.activefgtvm[0].id
  location           = azurerm_resource_group.myterraformgroup.location
  enabled            = true

  daily_recurrence_time = "2359"
  timezone              = "AUS Eastern Standard Time"


  notification_settings {
    enabled = false

  }
}

# resource "azurerm_role_assignment" "activefgvm_reader_role" {
#   scope                = "/subscriptions/${var.subscription_id}"
#   role_definition_name = "Reader"
#   principal_id         = azurerm_virtual_machine.activefgtvm[0].identity.0.principal_id
# }

# resource "azurerm_role_assignment" "activefgvm_networkcontributor_role" {
#   scope                = "/subscriptions/${var.subscription_id}"
#   role_definition_name = "Network Contributor"
#   principal_id         = azurerm_virtual_machine.activefgtvm[0].identity.0.principal_id
# }

resource "azurerm_role_assignment" "activefgvm_reader_role" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = azurerm_role_definition.sdn_connector_ha_role.name
  principal_id         = azurerm_virtual_machine.activefgtvm[0].identity.0.principal_id
}
