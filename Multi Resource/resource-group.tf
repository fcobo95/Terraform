resource "azurerm_resource_group" "multi-resource-rg-tf" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}
