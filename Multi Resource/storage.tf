resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.multi-resource-rg-tf.name
  location                 = azurerm_resource_group.multi-resource-rg-tf.location
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  is_hns_enabled           = true # Hierarchical namespace (Datalake)
  account_replication_type = "LRS"
  access_tier              = "Hot"
  tags                     = var.tags
}

# Using the *count* meta-argument to create multiple resources

/* resource "azurerm_storage_container" "storage_accounts_foreach" {
  count = 3
  name                     = "data${count.index}"
  storage_account_name = azurerm_storage_account.storage_account.name
  container_access_type = "blob"
} */

# Using the *for_each* meta-argument to create multiple resources

resource "azurerm_storage_container" "storage_accounts_foreach" {
  for_each              = toset(["data", "logs", "backup"])
  name                  = each.key
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "blob"
}

# Adding multiple files from different locations into the data containers

resource "azurerm_storage_blob" "files" {
  for_each = {
    file1 = "/Users/fcobo/Desktop/sc1.png",
    file2 = "/Users/fcobo/Documents/sc2.png",
    file3 = "/Users/fcobo/Downloads/sc3.png"
  }
  name                   = "${each.key}.png"
  storage_account_name   = azurerm_storage_account.storage_account.name
  storage_container_name = "data"
  type                   = "Block"
  source                 = each.value
}