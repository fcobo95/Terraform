resource "azurerm_resource_group" "terraform-training-rg" {
  name     = var.terraform_resource_group
  location = var.location
}
