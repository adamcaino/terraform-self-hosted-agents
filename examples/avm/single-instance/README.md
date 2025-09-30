## CICD Single-Instance Example with Terraform

This folder contains a small Terraform example that provisions a single-instance environment intended for CI/CD self-hosted-agent for demonstrating and testing purposes.

### Quick summary
- Deploys a Key Vault for secrets with a Linux and/or Windows virtual machine.
- The example uses native Terraform (i.e., no modules) and creates resources suitable for short-lived test environments or demos.
- The example platform resources (vNet, subnet, NSG, NAT Gateway) are expected to be already deployed (e.g., see the [_platform](../_platform) example).

### What is deployed (high level)
- Key Vault for secrets
- SSH public key and secrets stored in Key Vault
- Virtual Machine(s) — defined in `virtual_machines.linux.tf` and `virtual_machines.windows.tf`
- Public IPs for administrative connectivity to the VMs

### Resources consumed (billing considerations)
- **Virtual Machines** (default size `Standard_B2s`): Billed per hour while running.
- **Managed OS disks**: Billed per GB/month.
- **Public IP addresses** (per IP) if the VM(s) require direct public inbound access.
- **Key Vault**: Small monthly cost; API operation charges may apply.

### Notes
- This example is intended for demos and testing.
- Review VM sizes, images, identity, and key management before using in production.
- Costs vary by region and usage; consult the Azure Pricing Calculator for exact numbers.

## Deploy only Linux or only Windows
The Linux and Windows VM resources live in separate files. To deploy only one OS family, rename the file you don't want to deploy so it doesn't end with `.tf` (e.g. `virtual_machines.windows.tf.disabled`).

## Basic Terraform workflow

```bash
terraform init
terraform plan -out plan.tfplan
terraform apply plan.tfplan
```

## Developer notes
- Example variables are provided in `variables.tf` and can be overridden with `-var` or `*.tfvars` files. `vm_size` defaults to `Standard_B2s`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.46.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_avm_key_vault"></a> [avm\_key\_vault](#module\_avm\_key\_vault) | Azure/avm-res-keyvault-vault/azurerm | 0.10.1 |
| <a name="module_avm_linux_pip"></a> [avm\_linux\_pip](#module\_avm\_linux\_pip) | Azure/avm-res-network-publicipaddress/azurerm | 0.2.0 |
| <a name="module_avm_linux_vm"></a> [avm\_linux\_vm](#module\_avm\_linux\_vm) | Azure/avm-res-compute-virtualmachine/azurerm | 0.19.3 |
| <a name="module_avm_rg"></a> [avm\_rg](#module\_avm\_rg) | Azure/avm-res-resources-resourcegroup/azurerm | 0.2.1 |
| <a name="module_avm_ssh_public_key"></a> [avm\_ssh\_public\_key](#module\_avm\_ssh\_public\_key) | Azure/avm-res-compute-sshpublickey/azurerm | 0.1.0 |
| <a name="module_avm_windows_pip"></a> [avm\_windows\_pip](#module\_avm\_windows\_pip) | Azure/avm-res-network-publicipaddress/azurerm | 0.2.0 |
| <a name="module_avm_windows_vm"></a> [avm\_windows\_vm](#module\_avm\_windows\_vm) | Azure/avm-res-compute-virtualmachine/azurerm | 0.19.3 |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault_access_policy.current_user](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_secret.admin_password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.admin_ssh_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [random_password.admin](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [tls_private_key.admin_ssh_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_resource_group.platform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.compute](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | The admin username for the Virtual Machine. | `string` | `"azureadmin"` | no |
| <a name="input_cicd_vnet_name"></a> [cicd\_vnet\_name](#input\_cicd\_vnet\_name) | The name of the CI/CD virtual network to use when looking up the existing virtual network. | `string` | `"vnet-qc-cicd-platform-dev-uks-01"` | no |
| <a name="input_compute_subnet_name"></a> [compute\_subnet\_name](#input\_compute\_subnet\_name) | The name of the compute subnet to use when looking up the existing subnet. | `string` | `"snet-compute-dev-uks-01"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment for the deployment (e.g., dev, test, prod). | `string` | `"dev"` | no |
| <a name="input_key_vault_ip_rules"></a> [key\_vault\_ip\_rules](#input\_key\_vault\_ip\_rules) | List of IP addresses or CIDR ranges that are allowed to access the Key Vault. | `list(string)` | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region to deploy resources into. | <pre>object({<br/>    name      = string<br/>    shortcode = string<br/>  })</pre> | <pre>{<br/>  "name": "UK South",<br/>  "shortcode": "uks"<br/>}</pre> | no |
| <a name="input_platform_resource_group_name"></a> [platform\_resource\_group\_name](#input\_platform\_resource\_group\_name) | The name of the resource group to use when looking up the existing resource group. | `string` | `"rg-qc-cicd-platform-terraform-avm-dev-uks-01"` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | The Subscription ID which should be used to deploy resources in to. | `string` | n/a | yes |
| <a name="input_user_ip_address"></a> [user\_ip\_address](#input\_user\_ip\_address) | Your public IP address in CIDR notation. | `string` | n/a | yes |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | The size of the Virtual Machine. | `string` | `"Standard_B2s"` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Configuration details for the workload being deployed. | <pre>object({<br/>    name       = string<br/>    short_name = string<br/>  })</pre> | <pre>{<br/>  "name": "CICD Single Instance",<br/>  "short_name": "cicd-si"<br/>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->