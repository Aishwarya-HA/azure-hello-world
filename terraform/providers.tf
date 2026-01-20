
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.115.0"
    }
  }

  # 🔒 Remote state so CI always has the same state
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state-aish"
    storage_account_name = "aishterraformstate"   # must be globally unique; adjust if you used a different name
    container_name       = "tfstate"
    key                  = "hello-world.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
