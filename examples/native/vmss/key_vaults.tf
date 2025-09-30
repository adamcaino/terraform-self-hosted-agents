# Create a Key Vault to store the admin credentials
resource "azurerm_key_vault" "kv" {
  # Key Vault name must be globally unique and not greater than 24 characters
  name                = replace("kv${local.resource_short_name_base}01", "-", "") # "kvqccicdsidevuks01"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  # Key Vault settings
  sku_name                   = "standard"
  purge_protection_enabled   = false
  soft_delete_retention_days = 7

  # Network access settings
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = concat([var.user_ip_address], var.key_vault_ip_rules)
  }
}

resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id # The currently authenticated user

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
    "Purge"
  ]
}
