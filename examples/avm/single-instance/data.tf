# Get information about the current Azure client
data "azurerm_client_config" "current" {}

# Get the CI/CD resource group
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# Get the CI/CD compute subnet
data "azurerm_subnet" "compute" {
  name                 = var.compute_subnet_name
  virtual_network_name = var.cicd_vnet_name
  resource_group_name  = data.azurerm_resource_group.rg.name
}
