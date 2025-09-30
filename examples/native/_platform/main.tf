terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true # Permanently delete Key Vault when the resource is destroyed. Used for testing purposes only.
    }
  }

  subscription_id = var.subscription_id
}

# Get information about the current Azure client
data "azurerm_client_config" "current" {}

# Define local values to be used for naming resources
locals {
  # Format the workload name to be used for naming resources
  name_slug                = lower(replace(var.workload.name, " ", "-"))
  resource_name_prefix     = lower("${var.org.prefix}-${local.name_slug}")                                       # "qc-cicd-single-instance"
  resource_name_suffix     = lower("${var.environment}-${var.location.shortcode}")                               # "dev-uks"
  resource_name_base       = lower("${local.resource_name_prefix}-${local.resource_name_suffix}")                # "qc-cicd-single-instance-dev-uks"
  resource_short_name_base = lower("${var.org.prefix}-${var.workload.short_name}-${local.resource_name_suffix}") # "qc-cicd-si-dev-uks"
}

# Create the CI/CD resource group
resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.resource_name_base}-01"
  location = var.location.name
}
