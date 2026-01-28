terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      # Pin to a stable version to avoid recent regressions.
      version = "= 3.103.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.10"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
