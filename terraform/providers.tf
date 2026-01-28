terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.111"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
  }

  # Optional: Remote state backend (recommended)
  # backend "azurerm" {
  #   resource_group_name  = "rg-terraform-state"
  #   storage_account_name = "mystatetfstorage"
  #   container_name       = "tfstate"
  #   key                  = "hello-world-app.tfstate"
  #   use_azuread_auth     = true
  # }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Needed for data "template_file" rendering cloud-init
provider "template" {}
