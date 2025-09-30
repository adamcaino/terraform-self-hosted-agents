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

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.46.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_avm_cicd_rg"></a> [avm\_cicd\_rg](#module\_avm\_cicd\_rg) | Azure/avm-res-resources-resourcegroup/azurerm | 0.2.1 |
| <a name="module_avm_cicd_vnet"></a> [avm\_cicd\_vnet](#module\_avm\_cicd\_vnet) | Azure/avm-res-network-virtualnetwork/azurerm | 0.11.0 |
| <a name="module_avm_compute_nsg"></a> [avm\_compute\_nsg](#module\_avm\_compute\_nsg) | Azure/avm-res-network-networksecuritygroup/azurerm | 0.5.0 |
| <a name="module_avm_nat_gateway"></a> [avm\_nat\_gateway](#module\_avm\_nat\_gateway) | Azure/avm-res-network-natgateway/azurerm | 0.2.1 |

## Resources

| Name | Type |
|------|------|
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compute_subnet_address_prefixes"></a> [compute\_subnet\_address\_prefixes](#input\_compute\_subnet\_address\_prefixes) | The address prefix for the compute subnet. | `list(string)` | <pre>[<br/>  "192.168.0.0/24"<br/>]</pre> | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment for the deployment (e.g., dev, test, prod). | `string` | `"dev"` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region to deploy resources into. | <pre>object({<br/>    name      = string<br/>    shortcode = string<br/>  })</pre> | <pre>{<br/>  "name": "UK South",<br/>  "shortcode": "uks"<br/>}</pre> | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | The Subscription ID which should be used to deploy resources in to. | `string` | n/a | yes |
| <a name="input_user_ip_address"></a> [user\_ip\_address](#input\_user\_ip\_address) | Your public IP address in CIDR notation. | `string` | n/a | yes |
| <a name="input_vnet_address_space"></a> [vnet\_address\_space](#input\_vnet\_address\_space) | The address space for the virtual network. | `list(string)` | <pre>[<br/>  "192.168.0.0/16"<br/>]</pre> | no |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | The name of the workload being deployed. | `string` | `"CICD Platform"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->