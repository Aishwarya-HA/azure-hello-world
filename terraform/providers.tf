terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.111"
    }
  }

  # Optional: remote state backend (configure if you already use it)
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
