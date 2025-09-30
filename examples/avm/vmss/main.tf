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

# Create a resource group for the workload
module "avm_rg" {
  source  = "../../_platform/modules/resource-group"
  version = "1.0.0"

  name     = "rg-${local.resource_name_base}-01"
  location = var.location.name
}

# Define local values to be used for naming resources
locals {
  # Format the workload name to be used for naming resources
  resource_name_slug   = lower("qc-${replace(var.workload.name, " ", "-")}")   # "CICD Platform Terraform AVM" -> "qc-cicd-platform-terraform-avm"
  resource_name_suffix = lower("${var.environment}-${var.location.shortcode}") # "dev-uks"
}
