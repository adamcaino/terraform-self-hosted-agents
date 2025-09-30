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
  name         = "${var.workload.short_name}-vm-admin-ssh-key" # "cicd-si-vm-admin-ssh-key"
  value        = tls_private_key.admin_ssh_key.private_key_pem
  key_vault_id = azurerm_key_vault.kv.id

  # Ensure Key Vault is created before adding the secret and removes the secret first if the Key Vault is deleted
  depends_on = [azurerm_key_vault_access_policy.current_user]
}

# Create a Public IP for the VM
resource "azurerm_public_ip" "linux" {
  name                = "pip-${local.resource_name_prefix}-linux-${local.resource_name_suffix}-01" # "pip-qc-cicd-linux-dev-uks-01"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create a NIC for the VM
resource "azurerm_network_interface" "linux" {
  name                = "nic-${local.resource_name_prefix}-linux-${local.resource_name_suffix}-01" # "nic-qc-cicd-linux-dev-uks-01"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig-${local.resource_name_prefix}-linux-${local.resource_name_suffix}-01" # "ipconfig-qc-cicd-linux-dev-uks-01"
    subnet_id                     = data.azurerm_subnet.compute.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.linux.id
  }
}

# Create a Linux virtual machine
resource "azurerm_linux_virtual_machine" "cicd" {
  name                = "vm-${var.org.prefix}-cicd-linux-${var.environment}-${var.location.shortcode}-01" # "vm-qc-cicd-linux-dev-uks-01"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  size           = var.vm_size
  admin_username = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.admin_ssh_key.public_key_openssh
  }

  network_interface_ids = [
    azurerm_network_interface.linux.id,
  ]

  os_disk {
    name                 = "osdisk-${var.org.prefix}-cicd-linux-${var.environment}-${var.location.shortcode}-01" # "osdisk-qc-cicd-linux-dev-uks-01"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
