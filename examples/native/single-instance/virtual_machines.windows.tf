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

# Create a Public IP for the VM
resource "azurerm_public_ip" "windows" {
  name                = "pip-${local.resource_name_prefix}-windows-${local.resource_name_suffix}-01" # "pip-qc-cicd-dev-uks-01"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create a NIC for the VM
resource "azurerm_network_interface" "windows" {
  name                = "nic-${local.resource_name_prefix}-windows-${local.resource_name_suffix}-01" # "nic-qc-cicd-dev-uks-01"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig-${local.resource_name_prefix}-windows-${local.resource_name_suffix}-01" # "ipconfig-qc-cicd-dev-01"
    subnet_id                     = data.azurerm_subnet.compute.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.windows.id
  }
}

# Create a Windows virtual machine
resource "azurerm_windows_virtual_machine" "cicd" {
  name                = "vm-${local.resource_name_prefix}-windows-${local.resource_name_suffix}-01"           # "vm-qc-cicd-dev-uks-01"
  computer_name       = upper(replace("VM${var.workload.short_name}${local.resource_name_suffix}1", "-", "")) # "VMCICDSIDEVUKS1"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  size           = var.vm_size
  admin_username = var.admin_username
  admin_password = azurerm_key_vault_secret.admin_password.value

  network_interface_ids = [
    azurerm_network_interface.windows.id,
  ]

  os_disk {
    name                 = "osdisk-${local.resource_name_prefix}-cicd-windows-${local.resource_name_suffix}-01" # "osdisk-qc-cicd-windows-dev-uks-01"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-datacenter-smalldisk-g2"
    version   = "latest"
  }
}
