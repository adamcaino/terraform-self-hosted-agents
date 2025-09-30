# Create the NAT Gateway
module "avm_nat_gateway" {
  source  = "Azure/avm-res-network-natgateway/azurerm"
  version = "0.2.1"

  name                = "ngw-${local.resource_name_base}-01" # "ngw-qc-cicd-single-instance-dev-uks-01"
  location            = var.location.name
  resource_group_name = module.avm_cicd_rg.name

  # Create and associate a Public IP to the NAT Gateway
  public_ips = {
    pip0 = {
      name = "pip-${local.resource_name_prefix}-nat-gateway-${local.resource_name_suffix}-01" # "pip-qc-nat-gateway-dev-uks-01"
    }
  }
}
