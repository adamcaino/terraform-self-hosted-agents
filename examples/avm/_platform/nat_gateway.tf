# Create the NAT Gateway
module "avm_nat_gateway" {
  source  = "Azure/avm-res-network-natgateway/azurerm"
  version = "0.2.1"

  name                = "ngw-${local.name_prefix}-${local.name_suffix}-01" # "ngw-cicd-platform-dev-uks-01"
  location            = var.location.name
  resource_group_name = module.avm_cicd_rg.name

  # Create and associate a Public IP to the NAT Gateway
  public_ips = {
    pip0 = {
      name = "pip-${local.name_prefix}-nat-gateway-${local.name_suffix}-01" # "pip-cicd-platform-dev-uks-01"
    }
  }
}
