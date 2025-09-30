# Create an admin password for the Windows VM. Note that this will be stored in tfstate.
# For a production environment, consider using a more secure method, such as creating
# a random string outside of Terraform and passing it in as a variable.
resource "random_password" "admin" {
  length  = 16
  special = true
}

# Save the admin password in a Key Vault secret
resource "azurerm_key_vault_secret" "admin_password" {
  name         = "${var.workload.short_name}-vmss-admin-password" # "cicd-avm-admin-password"
  value        = random_password.admin.result
  key_vault_id = module.avm_key_vault.resource_id

  # Ensure Key Vault is created before adding the secret
  depends_on = [azurerm_key_vault_access_policy.current_user]
}

# Create a windows virtual machine
module "avm_windows_vm" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.19.3"

  name                = "vm-${local.resource_name_prefix}-windows-${local.resource_name_suffix}-01"           # "vm-qc-cicd-windows-dev-uks-01"
  computer_name       = upper(replace("VM${var.workload.short_name}${local.resource_name_suffix}1", "-", "")) # "VMCICDSIDEVUKS1"
  location            = var.location.name
  resource_group_name = data.azurerm_resource_group.rg.name

  os_type                    = "Windows"
  sku_size                   = var.vm_size # "Standard_B2s"
  zone                       = "1"
  encryption_at_host_enabled = false

  network_interfaces = {
    nic0 = {
      name = "nic-${local.resource_name_prefix}-windows-${local.resource_name_suffix}-01" # "nic-qc-cicd-windows-dev-uks-01"
      ip_configurations = {
        ipconfig0 = {
          name                          = "ipconfig"
          private_ip_subnet_resource_id = data.azurerm_subnet.compute.id
          public_ip_address_resource_id = module.avm_windows_pip.resource_id
        }
      }
    }
  }

  account_credentials = {
    admin_credentials = {
      username                           = var.admin_username
      password                           = azurerm_key_vault_secret.admin_password.value
      generate_admin_password_or_ssh_key = false
    }
  }

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-datacenter-smalldisk-g2"
    version   = "latest"
  }
}
