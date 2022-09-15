resource "azurerm_availability_set" "fgt_av_set" {
  count = var.availability_zone ? 0 : 1
  name                = "${var.rgname}-fgt-avset"
  location            = azurerm_resource_group.myterraformgroup.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  platform_fault_domain_count = 2

  tags = local.common_tags
  
}