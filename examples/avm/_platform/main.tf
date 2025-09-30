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
  features {}

  subscription_id = var.subscription_id # Required for AzureRM 4.x and above
}

# Get information about the current Azure client
data "azurerm_client_config" "current" {}

# Define local values to be used for naming resources
locals {
  # Format the workload name to be used for naming resources
  name_prefix = lower(replace(var.workload_name, " ", "-"))           # "cicd-platform"
  name_suffix = lower("${var.environment}-${var.location.shortcode}") # "dev-uks"
}

# Create the CI/CD resource group
module "avm_cicd_rg" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"

  name     = "rg-${local.name_prefix}-terraform-avm-${local.name_suffix}-01" # "rg-cicd-platform-terraform-avm-dev-uks-01"
  location = var.location.name
}
