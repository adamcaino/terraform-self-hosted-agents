# Create a Key Vault to store the admin credentials
module "avm_key_vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.10.1"

  # Key Vault name must be globally unique and not greater than 24 characters
  name                = replace("kv${local.short_name_prefix}${local.name_suffix}01", "-", "") # "kvcicdtfavmdevuks01"
  location            = var.location.name
  resource_group_name = module.avm_rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  purge_protection_enabled   = false
  soft_delete_retention_days = 7

  legacy_access_policies_enabled = true # For production use, consider using RBAC to manage access to the Key Vault.

  network_acls = {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = concat([var.user_ip_address], var.key_vault_ip_rules)
  }
}

# While the AVM supports assigning access policies directly to the Key Vault module,
# we need to assign an access policy to the currently authenticated user to allow
# creation of Key Vault secrets in this example.
resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = module.avm_key_vault.resource_id
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
