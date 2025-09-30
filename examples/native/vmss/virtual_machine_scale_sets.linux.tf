# Create an SSH public key for the admin user
resource "tls_private_key" "admin_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Upload the SSH public key to Azure
resource "azurerm_ssh_public_key" "admin_ssh_key" {
  name                = "sshkey-${local.resource_name_prefix}-linux-${local.resource_name_suffix}-01" # "sshkey-qc-cicd-linux-dev-uks-01"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  public_key = tls_private_key.admin_ssh_key.public_key_openssh
}

# Save the SSH private key in a Key Vault secret
resource "azurerm_key_vault_secret" "admin_ssh_key" {
  name         = "${var.workload.short_name}-vmss-admin-ssh-key" # "cicd-tf-vmss-admin-ssh-key"
  value        = tls_private_key.admin_ssh_key.private_key_pem
  key_vault_id = azurerm_key_vault.kv.id

  # Ensure Key Vault is created before adding the secret and removes the secret first if the Key Vault is deleted
  depends_on = [azurerm_key_vault_access_policy.current_user]
}

resource "azurerm_linux_virtual_machine_scale_set" "cicd" {
  name                = "vmss-${var.org.prefix}-cicd-linux-${var.environment}-${var.location.shortcode}-01" # "vmss-qc-cicd-linux-dev-uks-01"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  sku                  = "Standard_B2s"
  instances            = 1
  computer_name_prefix = "vm-"

  admin_username = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.admin_ssh_key.public_key_openssh
  }

  # Required for Azure DevOps self-hosted agents
  overprovision          = false
  single_placement_group = true

  network_interface {
    name    = "nic-${local.resource_short_name_base}-01" # "nic-qc-cicd-tf-dev-uks-01"
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
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
