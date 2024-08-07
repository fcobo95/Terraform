# create empty storage account
resource "azurerm_storage_account" "storageaccount" {
  name                     = var.storage_name
  location                 = azurerm_resource_group.terraform-training-rg.location
  resource_group_name      = azurerm_resource_group.terraform-training-rg.name
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  is_hns_enabled           = true # Hierarchical namespace (Datalake)
  account_replication_type = "LRS"
  access_tier              = "Hot"
  tags = var.tags
}

#create storage account container
resource "azurerm_storage_container" "data" {
  name                 = var.storage_container_name
  storage_account_name = azurerm_storage_account.storageaccount.name
}

/* resource "azurerm_storage_blob" "main" {
  name                   = "main.tf"
  storage_account_name   = var.storage_name
  storage_container_name = var.storage_container_name
  type                   = "Block"
  source                 = "C:\\Users\\Fernando\\Desktop\\Terraform\\main.tf"
  depends_on = [
    azurerm_storage_container.data
  ]
} */
