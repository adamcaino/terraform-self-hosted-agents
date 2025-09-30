# Create a Network Security Group for the compute subnet
resource "azurerm_network_security_group" "compute" {
  name                = "nsg-${local.resource_name_prefix}-compute-${local.resource_name_suffix}-01" # "nsg-qc-cicd-dev-uks-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Define security rules for the NSG.
  # Best practice sees these defined in a "locals" block for better organisation and logic handling.
  # They are defined here for simplicity.
  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.user_ip_address
    destination_address_prefix = azurerm_subnet.compute.address_prefixes[0]
    description                = "Allow SSH inbound traffic"
  }

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = var.user_ip_address
    destination_address_prefix = azurerm_subnet.compute.address_prefixes[0]
    description                = "Allow RDP inbound traffic"
  }
}

resource "azurerm_subnet_network_security_group_association" "cicd" {
  subnet_id                 = azurerm_subnet.compute.id
  network_security_group_id = azurerm_network_security_group.compute.id
}
