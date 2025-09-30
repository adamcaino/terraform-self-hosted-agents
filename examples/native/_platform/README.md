## CICD Single-Instance Example with Terraform

This folder contains a small Terraform example that provisions a single-instance environment intended for CI/CD self-hosted-agent for demonstrating and testing purposes.

### Quick summary
- Deploys a foundational platform landing zone, consisting of a virtual network, network security group, subnet, and a NAT Gateway for outbound internet connectivity.
- This example uses native Terraform (i.e., no modules) and creates resources suitable for short-lived test environments or demos.

### What is deployed (high level)
- Resource Group
- Virtual Network and subnet
- Network Security Group
- NAT Gateway for outbound internet access

### Resources consumed (billing considerations)
- **Network resources** (vNet, subnets): Usually low-cost but subject to regional pricing.
- **NAT Gateway**: Billed per hour plus data processed (egress). Useful to centralize outbound IPs but has ongoing cost.
- **Public IP addresses** (per IP) if the VM(s) require direct public inbound access.

### Notes
- This example is intended for demos and testing.
- Review identity and key management before using in production.
- Costs vary by region and usage; consult the Azure Pricing Calculator for exact numbers.

## Basic Terraform workflow

```bash
terraform init
terraform plan -out plan.tfplan
terraform apply plan.tfplan
```

## Developer notes
- Example variables are provided in `variables.tf` and can be overridden with `-var` or `*.tfvars` files.
- The NAT Gateway module provides a single egress IP (and cost). If you don't need NAT, adjust `main.tf` to remove or disable it.
  - This is the recommended approach from September 2025 (see [Default outbound access in Azure](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/default-outbound-access) for more information).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_nat_gateway.cicd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway) | resource |
| [azurerm_nat_gateway_public_ip_association.nat_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway_public_ip_association) | resource |
| [azurerm_network_security_group.compute](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_public_ip.nat_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.compute](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_nat_gateway_association.nat_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_nat_gateway_association) | resource |
| [azurerm_subnet_network_security_group_association.cicd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_virtual_network.cicd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compute_subnet_address_prefix"></a> [compute\_subnet\_address\_prefix](#input\_compute\_subnet\_address\_prefix) | The address prefix for the compute subnet. | `string` | `"192.168.0.0/24"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment for the deployment (e.g., dev, test, prod). | `string` | `"dev"` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region to deploy resources into. | <pre>object({<br/>    name      = string<br/>    shortcode = string<br/>  })</pre> | <pre>{<br/>  "name": "UK South",<br/>  "shortcode": "uks"<br/>}</pre> | no |
| <a name="input_my_ip_address"></a> [my\_ip\_address](#input\_my\_ip\_address) | Your public IP address in CIDR notation. | `string` | n/a | yes |
| <a name="input_org"></a> [org](#input\_org) | Configuration details for the organisation, to be used for naming and tags for all resources created. | <pre>object({<br/>    name   = string<br/>    prefix = string<br/>  })</pre> | <pre>{<br/>  "name": "Quadrivium Cloud",<br/>  "prefix": "qc"<br/>}</pre> | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | The Subscription ID which should be used to deploy resources in to. | `string` | n/a | yes |
| <a name="input_vnet_address_space"></a> [vnet\_address\_space](#input\_vnet\_address\_space) | The address space for the virtual network. | `list(string)` | <pre>[<br/>  "192.168.0.0/16"<br/>]</pre> | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Configuration details for the workload being deployed. | <pre>object({<br/>    name       = string<br/>    short_name = string<br/>  })</pre> | <pre>{<br/>  "name": "CICD Single Instance",<br/>  "short_name": "cicd-si"<br/>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->