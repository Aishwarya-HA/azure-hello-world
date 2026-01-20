
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.11"
    }
  }

  # Remote state in Azure Storage (uses OIDC/Azure AD auth via your GitHub Action)
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state-aish"
    storage_account_name = "aishterraformstate"
    container_name       = "tfstate"
    key                  = "hello-world.tfstate"
    use_azuread_auth     = true
  }
}

# AzureRM provider
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  # If you ever see provider registration delays, you can optionally add:
  # skip_provider_registration = true
}

# time provider (needed for time_sleep resources)
provider "time" {}
