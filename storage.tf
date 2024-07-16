# create empty storage account
resource "azurerm_storage_account" "storageaccount" {
  name                     = var.storage_name
  location                 = var.location
  resource_group_name      = var.resource_group
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  is_hns_enabled           = true # Hierarchical namespace (Datalake)
  account_replication_type = "LRS"
  access_tier              = "Hot"
  depends_on = [
    azurerm_resource_group.rg
  ]
}

#create storage account container
resource "azurerm_storage_container" "data" {
  name                 = var.storage_container_name
  storage_account_name = var.storage_name
  depends_on = [
    azurerm_storage_account.storageaccount
  ]
}

resource "azurerm_storage_blob" "main" {
  name                   = "main.tf"
  storage_account_name   = var.storage_name
  storage_container_name = var.storage_container_name
  type                   = "Block"
  source                 = "C:\\Users\\Fernando\\Desktop\\Terraform\\main.tf"
  depends_on = [
    azurerm_storage_container.data
  ]
}
