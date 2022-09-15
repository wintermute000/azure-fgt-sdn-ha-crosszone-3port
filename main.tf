// Resource Group

resource "azurerm_resource_group" "myterraformgroup" {
  name     = var.rgname
  location = var.location

  tags = local.common_tags
}
