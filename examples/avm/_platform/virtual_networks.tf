# Create a virtual network
module "avm_cicd_vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.11.0"

  name          = "vnet-${local.name_prefix}-${local.name_suffix}-01" # "vnet-cicd-platform-dev-uks-01"
  parent_id     = module.avm_cicd_rg.resource_id                      # The resource ID of the resource group to create the VNet in
  location      = var.location.name                                   # Location for the VNet, typically the same as the resource group its deployed in
  address_space = var.vnet_address_space                              # The address space for the VNet

  # Create the "compute" subnet within the virtual network
  subnets = {
    compute = {
      name                   = "snet-compute-${local.name_suffix}-01" # "snet-compute-dev-uks-01"
      address_prefixes       = var.compute_subnet_address_prefixes
      network_security_group = { id = module.avm_compute_nsg.resource_id } # Associate the "compute" NSG  with the "compute" subnet
      nat_gateway            = { id = module.avm_nat_gateway.resource_id } # Associate the NAT Gateway  with the "compute" subnet
    }
  }
}
