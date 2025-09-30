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
  name_prefix       = lower("${var.org.prefix}-${replace(var.workload.name, " ", "-")}")       # "qc-cicd-terraform-avm"
  short_name_prefix = lower("${var.org.prefix}-${replace(var.workload.short_name, " ", "-")}") # "qc-cicd-tf-avm"
  name_suffix       = lower("${var.environment}-${var.location.shortcode}")                    # "dev-uks"
}

# Create a resource group for the workload
module "avm_rg" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"

  name     = "rg-${local.name_prefix}-terraform-avm-${local.name_suffix}-01" # "rg-qc-cicd-terraform-avm-single-instance-dev-uks-01"
  location = var.location.name
}
