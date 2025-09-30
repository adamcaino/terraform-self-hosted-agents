# Create a random password for the admin user
resource "random_password" "admin_password" {
  length           = 16
  special          = true
  override_special = "!@#$%&*()-_=+[]{}<>:?"
}

# Save the admin password in a Key Vault secret
resource "azurerm_key_vault_secret" "admin_password" {
  name         = "cicd-vms-admin-password"
  value        = random_password.admin_password.result
  key_vault_id = azurerm_key_vault.kv.id

  # Ensure Key Vault is created before adding the secret
  depends_on = [azurerm_key_vault_access_policy.current_user]
}

resource "azurerm_windows_virtual_machine_scale_set" "cicd" {
  name                = "vmss-${var.org.prefix}-cicd-windows-${var.environment}-${var.location.shortcode}-01" # "vmss-qc-cicd-windows-dev-uks-01"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  sku                  = "Standard_B2s"
  instances            = 1
  computer_name_prefix = "vm-"

  admin_password = random_password.admin_password.result
  admin_username = "azureadmin"

  # Required for Azure DevOps self-hosted agents
  overprovision          = false
  single_placement_group = true

  network_interface {
    name    = "nic-${local.resource_short_name_base}-01" # "nic-qc-cicd-si-dev-uks-01"
    primary = true

    ip_configuration {
      name      = "ipconfig"
      subnet_id = data.azurerm_subnet.compute.id
      primary   = true
    }
  }

  os_disk {
    storage_account_type = "StandardSSD_LRS"
    caching              = "ReadWrite"
  }

  # To see available images, run:
  # az vm image list-skus --location <region> --publisher MicrosoftWindowsServer --offer WindowsServer --output table
  # Use an Azure Marketplace image or a custom image
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-datacenter-core-smalldisk-g2"
    version   = "latest"
  }
}
