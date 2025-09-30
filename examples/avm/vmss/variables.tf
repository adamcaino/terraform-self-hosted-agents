variable "subscription_id" {
  description = "The Subscription ID which should be used to deploy resources in to."
  type        = string
}

variable "org" {
  description = "Configuration details for the organisation, to be used for naming and tags for all resources created."
  type = object({
    name   = string
    prefix = string
  })
  default = {
    name   = "Quadrivium Cloud"
    prefix = "qc"
  }
}

variable "workload" {
  description = "Configuration details for the workload being deployed."
  type = object({
    name       = string
    short_name = string
  })
  default = {
    name = "CICD Terraform AVM"
    slug = "cicd-tf-avm"
  }
}

variable "environment" {
  description = "The environment for the deployment (e.g., dev, test, prod)."
  type        = string
  default     = "dev"
}

variable "location" {
  description = "The Azure region to deploy resources into."
  type = object({
    name      = string
    shortcode = string
  })
  default = {
    name      = "UK South"
    shortcode = "uks"
  }
}

# -- Existing resource references --
# Hardcoded for simplicity in this example, but should be looked up programmatically in a production deployment
variable "resource_group_name" {
  description = "The name of the resource group to use when looking up the existing resource group."
  type        = string
  default     = "rg-qc-cicd-tf-avm-dev-uks-01"
}

variable "cicd_vnet_name" {
  description = "The name of the CI/CD virtual network to use when looking up the existing virtual network."
  type        = string
  default     = "vnet-qc-cicd-tf-avm-dev-uks-01"
}

variable "compute_subnet_name" {
  description = "The name of the compute subnet to use when looking up the existing subnet."
  type        = string
  default     = "snet-compute-dev-uks-01"
}

# -- Key Vault variables --
variable "user_ip_address" {
  description = "Your public IP address in CIDR notation."
  type        = string
}

variable "key_vault_ip_rules" {
  description = "List of IP addresses or CIDR ranges that are allowed to access the Key Vault."
  type        = list(string)
  default     = []
}

# -- Virtual Machine variables --
variable "admin_username" {
  description = "The admin username for the Virtual Machine."
  type        = string
  default     = "azureadmin"
}

variable "vm_size" {
  description = "The size of the Virtual Machine."
  type        = string
  default     = "Standard_B2s"
}
