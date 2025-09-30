# Create a virtual network
resource "azurerm_virtual_network" "cicd" {
  name                = "vnet-${local.resource_name_base}-01" # "vnet-qc-cicd-single-instance-dev-uks-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.vnet_address_space
}

# Create the "compute" subnet within the virtual network
resource "azurerm_subnet" "compute" {
  name                 = "snet-compute-${local.resource_name_suffix}-01"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.cicd.name
  address_prefixes     = var.compute_subnet_address_prefixes
}
