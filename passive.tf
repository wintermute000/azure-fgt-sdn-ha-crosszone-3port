# resource "azurerm_virtual_machine" "custompassivefgtvm" {
#   depends_on                   = [azurerm_virtual_machine.customactivefgtvm]
#   count                        = var.custom ? 1 : 0
#   name                         = "custompassivefgt"
#   location                     = var.location
#   resource_group_name          = azurerm_resource_group.myterraformgroup.name
#   network_interface_ids        = [azurerm_network_interface.passiveport1.id, azurerm_network_interface.passiveport2.id, azurerm_network_interface.passiveport3.id]
#   primary_network_interface_id = azurerm_network_interface.passiveport1.id
#   vm_size                      = var.size
#   zones                        = [var.zone2]

#   delete_os_disk_on_termination    = true
#   delete_data_disks_on_termination = true

#   storage_image_reference {
#     id = var.custom ? element(azurerm_image.custom.*.id, 0) : null
#   }

#   storage_os_disk {
#     name              = "passiveosDisk"
#     caching           = "ReadWrite"
#     managed_disk_type = "Standard_LRS"
#     create_option     = "FromImage"
#   }

#   # Log data disks
#   storage_data_disk {
#     name              = "passivedatadisk"
#     managed_disk_type = "Standard_LRS"
#     create_option     = "Empty"
#     lun               = 0
#     disk_size_gb      = "30"
#   }

#   os_profile {
#     computer_name  = "custompassivefgt"
#     admin_username = var.adminusername
#     admin_password = var.adminpassword
#     custom_data = templatefile("${var.bootstrap-passive}", {
#       type            = var.license_type
#       license_file    = var.license2
#       port1_ip        = var.passiveport1
#       port1_mask      = var.passiveport1mask
#       port2_ip        = var.passiveport2
#       port2_mask      = var.passiveport2mask
#       port3_ip        = var.passiveport3
#       port3_mask      = var.passiveport3mask
#       active_peerip   = var.activeport1
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


resource "azurerm_virtual_machine" "passivefgtvm" {
  depends_on                       = [azurerm_virtual_machine.activefgtvm, azurerm_role_definition.sdn_connector_ha_role, ]
  count                            = var.custom ? 0 : 1
  name                             = var.passivename
  location                         = var.location
  resource_group_name              = azurerm_resource_group.myterraformgroup.name
  network_interface_ids            = [azurerm_network_interface.passiveport1.id, azurerm_network_interface.passiveport2.id, azurerm_network_interface.passiveport3.id]
  primary_network_interface_id     = azurerm_network_interface.passiveport1.id
  vm_size                          = var.size
  zones                            = var.availability_zone ? [var.zone2] : null
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
    name              = "${var.passivename}-osDisk"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    create_option     = "FromImage"
  }

  # Log data disks
  storage_data_disk {
    name              = "${var.passivename}-datadisk"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "30"
  }

  os_profile {
    computer_name  = var.passivename
    admin_username = var.adminusername
    admin_password = var.adminpassword
    custom_data = templatefile("${var.bootstrap-passive}", {
      type            = var.license_type
      license_file    = var.fgtlicense != "" ? "./licenses/${var.fgtlicense2}" : ""
      passivename     = var.passivename
      port1_ip        = var.passiveport1
      port1_mask      = var.passiveport1mask
      port2_ip        = var.passiveport2
      port2_mask      = var.passiveport2mask
      port3_ip        = var.passiveport3
      port3_mask      = var.passiveport3mask
      active_peerip   = var.activeport1
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
      port2name      = "${var.passivename}-port2"
      rsg            = azurerm_resource_group.myterraformgroup.name
      clusterip      = azurerm_public_ip.ClusterPublicIP.name
      routetablename = azurerm_route_table.private_rt.name
      fgtflextoken   = var.fgtflextoken2
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


}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "passivefgtvm_shutdown_schedule" {
  virtual_machine_id = azurerm_virtual_machine.passivefgtvm[0].id
  location           = azurerm_resource_group.myterraformgroup.location
  enabled            = true

  daily_recurrence_time = "2359"
  timezone              = "AUS Eastern Standard Time"


  notification_settings {
    enabled = false

  }
}

# resource "azurerm_role_assignment" "passivefgvm_reader_role" {
#   scope                = "/subscriptions/${var.subscription_id}"
#   role_definition_name = "Reader"
#   principal_id         = azurerm_virtual_machine.passivefgtvm[0].identity.0.principal_id
# }

# resource "azurerm_role_assignment" "passivefgvm_networkcontributor_role" {
#   scope                = "/subscriptions/${var.subscription_id}"
#   role_definition_name = "Network Contributor"
#   principal_id         = azurerm_virtual_machine.passivefgtvm[0].identity.0.principal_id
# }

resource "azurerm_role_assignment" "passivefgvm_reader_role" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = azurerm_role_definition.sdn_connector_ha_role.name
  principal_id         = azurerm_virtual_machine.passivefgtvm[0].identity.0.principal_id
}
