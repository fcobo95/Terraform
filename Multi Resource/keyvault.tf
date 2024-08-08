resource "azurerm_key_vault" "keyvault" {
  name                        = var.key_vault_name
  location                    = azurerm_resource_group.multi-resource-rg-tf.location
  resource_group_name         = azurerm_resource_group.multi-resource-rg-tf.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true

  sku_name = "premium"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "List",
      "Delete",
      "Get",
      "Purge",
      "Recover",
      "Update",
      "GetRotationPolicy",
      "SetRotationPolicy",
    ]

    secret_permissions = [
      "Set",
    ]
  }
  tags = var.tags
}

resource "azurerm_key_vault_secret" "vmpassword" {
  name = "vmspassword"
  value = "Passw0rd"
  key_vault_id = azurerm_key_vault.keyvault.id
}
