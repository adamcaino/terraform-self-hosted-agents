# Create a Public IP for the NAT Gateway
resource "azurerm_public_ip" "nat_gateway" {
  name                = "pip-${local.resource_name_prefix}-nat-gateway-${local.resource_name_suffix}-01" # "pip-qc-cicd-nat-gateway-dev-uks-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  allocation_method = "Static"
  sku               = "Standard"
}

# Create the NAT Gateway
resource "azurerm_nat_gateway" "cicd" {
  name                = "ngw-${local.resource_name_prefix}-nat-gateway-${local.resource_name_suffix}-01" # "ngw-qc-cicd-nat-gateway-dev-uks-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  idle_timeout_in_minutes = 4
}

# Associate the Public IP to the NAT Gateway
resource "azurerm_nat_gateway_public_ip_association" "nat_gateway" {
  nat_gateway_id       = azurerm_nat_gateway.cicd.id
  public_ip_address_id = azurerm_public_ip.nat_gateway.id
}

# Associate the NAT Gateway to the NAT Gateway subnet
resource "azurerm_subnet_nat_gateway_association" "nat_gateway" {
  subnet_id      = azurerm_subnet.compute.id
  nat_gateway_id = azurerm_nat_gateway.cicd.id
}
