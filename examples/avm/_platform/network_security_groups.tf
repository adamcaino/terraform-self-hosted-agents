# Create a Network Security Group for the CICD subnet
module "avm_compute_nsg" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.5.0"

  name                = "nsg-${local.name_prefix}-compute-${local.name_suffix}-01" # "nsg-qc-cicd-platform-compute-dev-uks-01"
  location            = var.location.name
  resource_group_name = module.avm_cicd_rg.name

  # Define security rules for the NSG.
  # Best practice sees these defined in a "locals" block for better organisation and logic handling.
  # They are defined here for simplicity.
  security_rules = {
    allow_ssh = {
      name                       = "Allow-SSH"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = var.user_ip_address
      destination_address_prefix = var.compute_subnet_address_prefixes[0]
      description                = "Allow SSH inbound traffic"
    }

    allow_rdp = {
      name                       = "Allow-RDP"
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3389"
      source_address_prefix      = var.user_ip_address
      destination_address_prefix = var.compute_subnet_address_prefixes[0]
      description                = "Allow RDP inbound traffic"
    }
  }
}
