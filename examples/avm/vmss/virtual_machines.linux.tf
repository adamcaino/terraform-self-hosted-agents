# Create an SSH public key for the admin user
resource "tls_private_key" "admin_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Upload the SSH public key to Azure
module "avm_ssh_public_key" {
  source  = "Azure/avm-res-compute-sshpublickey/azurerm"
  version = "0.1.0"

  name                = replace("sshkey${local.resource_name_prefix}linux${local.resource_name_suffix}01", "-", "") # "sshkeyqccicdsingleinstancelinuxdevuks01"
  resource_group_name = data.azurerm_resource_group.rg.name
  public_key          = tls_private_key.admin_ssh_key.public_key_openssh
}

# Save the SSH private key in a Key Vault secret
resource "azurerm_key_vault_secret" "admin_ssh_key" {
  name         = "${var.workload.short_name}-vm-admin-ssh-key" # "cicd-si-vm-admin-ssh-key"
  value        = tls_private_key.admin_ssh_key.private_key_pem
  key_vault_id = module.avm_key_vault.resource_id

  # Ensure Key Vault is created before adding the secret and removes the secret first if the Key Vault is deleted
  depends_on = [azurerm_key_vault_access_policy.current_user]
}

# Create a Linux Virtual Machine Scale Set
module "avm_linux_vm" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.19.3"

  name                = "vm-${local.resource_name_prefix}-linux-${local.resource_name_suffix}-01" # "vm-qc-cicd-linux-dev-uks-01"
  location            = var.location.name
  resource_group_name = data.azurerm_resource_group.rg.name

  os_type                    = "Linux"
  sku_size                   = var.vm_size # "Standard_B2s"
  zone                       = "1"
  encryption_at_host_enabled = false

  network_interfaces = {
    nic0 = {
      name = "nic-${local.resource_name_prefix}-linux-${local.resource_name_suffix}-01" # "nic-qc-cicd-linux-dev-uks-01"
      ip_configurations = {
        ipconfig0 = {
          name                          = "ipconfig"
          private_ip_subnet_resource_id = data.azurerm_subnet.compute.id
          public_ip_address_resource_id = module.avm_linux_pip.resource_id
        }
      }
    }
  }

  account_credentials = {
    admin_credentials = {
      username                           = var.admin_username
      ssh_keys                           = [tls_private_key.admin_ssh_key.public_key_openssh]
      generate_admin_password_or_ssh_key = false
    }
  }

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
