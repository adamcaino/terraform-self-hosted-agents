terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
    key_vault {
      # This setting allows Key Vaults to be destroyed even if they contain soft-deleted secrets
      # Note: Use with caution in production environments
      purge_soft_delete_on_destroy = true
    }
  }

  subscription_id = var.subscription_id # Required for AzureRM 4.x and above
}

# Define local values to be used for naming resources
locals {
  # Format the workload name to be used for naming resources
  name_slug                = lower(replace(var.workload.name, " ", "-"))
  resource_name_prefix     = lower("${var.org.prefix}-${local.name_slug}")                                       # "qc-cicd-single-instance"
  resource_name_suffix     = lower("${var.environment}-${var.location.shortcode}")                               # "dev-uks"
  resource_name_base       = lower("${local.resource_name_prefix}-${local.resource_name_suffix}")                # "qc-cicd-single-instance-dev-uks"
  resource_short_name_base = lower("${var.org.prefix}-${var.workload.short_name}-${local.resource_name_suffix}") # "qc-cicd-si-dev-uks"
}
