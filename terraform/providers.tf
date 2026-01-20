
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.115.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-terraform-state-aish"
    storage_account_name = "aishterraformstate"
    container_name       = "tfstate"
    key                  = "hello-world.tfstate"
    use_azuread_auth     = true
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
