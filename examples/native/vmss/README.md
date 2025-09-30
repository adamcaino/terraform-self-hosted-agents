## CICD Virtual Machine Scale Set Example with Terraform

This folder contains a small Terraform example that provisions a virtual machine scale set environment intended for CI/CD self-hosted-agent for demonstrating and testing purposes.

### Quick summary
- Deploys a Key Vault for secrets with a Linux and/or Windows virtual machine.
- The example uses native Terraform (i.e., no modules) and creates resources suitable for short-lived test environments or demos.
- The example platform resources (vNet, subnet, NSG, NAT Gateway) are expected to be already deployed (e.g., see the [_platform](../_platform) example).

### What is deployed (high level)
- Key Vault for secrets
- SSH public key and secrets stored in Key Vault
- Virtual Machine Scale Set(s) — defined in `virtual_machine_scale_sets.linux.tf` and `virtual_machine_scale_sets.windows.tf`
- Public IPs for administrative connectivity to the VMSS

### Resources consumed (billing considerations)
- **Virtual Machines** (default size `Standard_B2s`): Billed per hour while running.
- **Managed OS disks**: Billed per GB/month.
- **Public IP addresses** (per IP) if the VMSS require direct public inbound access.
- **Key Vault**: Small monthly cost; API operation charges may apply.

### Notes
- This example is intended for demos and testing.
- Review VM sizes, images, identity, and key management before using in production.
- Costs vary by region and usage; consult the Azure Pricing Calculator for exact numbers.

## Deploy only Linux or only Windows
The Linux and Windows VM resources live in separate files. To deploy only one OS family, rename the file you don't want to deploy so it doesn't end with `.tf` (e.g. `virtual_machine_scale_sets.windows.tf.disabled`).

## Basic Terraform workflow

```bash
terraform init
terraform plan -out plan.tfplan
terraform apply plan.tfplan
```

## Developer notes
- Example variables are provided in `variables.tf` and can be overridden with `-var` or `*.tfvars` files. `vm_size` defaults to `Standard_B2s`.

## Configuring a VMSS Agent Pool in Azure DevOps
### Organization-level setup
1. In your Azure DevOps organization, navigate to **Organization Settings** > **Agent Pools** (under **Pipelines**).
2. Click **Add Pool** and select **Azure virtual machine scale set**.
3. Select a Service Connection or Subscription to connect the VMSS to.
4. Select the subscription where your VMSS is deployed.
5. Select the Virtual machine scale set from the dropdown.
6. Provide a display name for the agent pool. This will be the name you use to reference this pool in your pipelines.
7. Configure the pool options accordingly. This can be changed later if needed.
8. Click **Create** to finalize the setup.

## Project-level setup
9. Navigate to your project in Azure DevOps, then go to **Project Settings** > **Pipelines** > **Agent Pools**.
10. Click **Add Pool** and select **Existing**.
10. Select the agent pool you just created at the organization level and click **Create**.
11. You can now use this agent pool in your pipeline YAML files by specifying the pool name.

Azure DevOps will then connect to the VMSS and start provisioning agents based on the VMSS configuration. You can monitor the status of the agents in the Agent Pools section. There may be a short delay before the agents appear as available, but there is no need to manually install the Azure Pipelines agent on the VMSS instances nor manually spin up or down instances; this is handled automatically by Azure DevOps.

## Image Mangement
The example uses the latest available platform images from the Azure Marketplace. For production use, consider using a custom image or image versioning strategy to ensure consistency and control over updates.

Best practices for managing VM images in a production environment include:
- Using HashiCorp Packer or Azure Image Builder to automatically create and maintain custom images with pre-installed software and configurations.
- Manually updating golden images to include the latest security patches and software updates.
- Implementing a versioning strategy to track and deploy specific image versions for consistency across deployments and easy rollback if needed.

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

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.kv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_access_policy.current_user](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_secret.admin_password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.admin_ssh_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_linux_virtual_machine_scale_set.cicd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) | resource |
| [azurerm_ssh_public_key.admin_ssh_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/ssh_public_key) | resource |
| [azurerm_windows_virtual_machine_scale_set.cicd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine_scale_set) | resource |
| [random_password.admin_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [tls_private_key.admin_ssh_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.compute](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | The admin username for the Virtual Machine. | `string` | `"azureadmin"` | no |
| <a name="input_cicd_vnet_name"></a> [cicd\_vnet\_name](#input\_cicd\_vnet\_name) | The name of the CI/CD virtual network to use when looking up the existing virtual network. | `string` | `"vnet-qc-cicd-terraform-dev-uks-01"` | no |
| <a name="input_compute_subnet_name"></a> [compute\_subnet\_name](#input\_compute\_subnet\_name) | The name of the compute subnet to use when looking up the existing subnet. | `string` | `"snet-compute-dev-uks-01"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment for the deployment (e.g., dev, test, prod). | `string` | `"dev"` | no |
| <a name="input_key_vault_ip_rules"></a> [key\_vault\_ip\_rules](#input\_key\_vault\_ip\_rules) | List of IP addresses or CIDR ranges that are allowed to access the Key Vault. | `list(string)` | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region to deploy resources into. | <pre>object({<br/>    name      = string<br/>    shortcode = string<br/>  })</pre> | <pre>{<br/>  "name": "UK South",<br/>  "shortcode": "uks"<br/>}</pre> | no |
| <a name="input_org"></a> [org](#input\_org) | Configuration details for the organisation, to be used for naming and tags for all resources created. | <pre>object({<br/>    name   = string<br/>    prefix = string<br/>  })</pre> | <pre>{<br/>  "name": "Quadrivium Cloud",<br/>  "prefix": "qc"<br/>}</pre> | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group to use when looking up the existing resource group. | `string` | `"rg-qc-cicd-terraform-dev-uks-01"` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | The Subscription ID which should be used to deploy resources in to. | `string` | n/a | yes |
| <a name="input_user_ip_address"></a> [user\_ip\_address](#input\_user\_ip\_address) | Your public IP address in CIDR notation. | `string` | n/a | yes |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | The size of the Virtual Machine. | `string` | `"Standard_B2s"` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Configuration details for the workload being deployed. | <pre>object({<br/>    name       = string<br/>    short_name = string<br/>  })</pre> | <pre>{<br/>  "name": "CICD Terraform",<br/>  "short_name": "cicd-tf"<br/>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->