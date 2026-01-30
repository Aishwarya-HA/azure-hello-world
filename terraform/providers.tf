terraform {
  required_version = ">= 1.6.0"

  # Remote state backend: Azure Blob Storage
  backend "azurerm" {
    # ---- CHANGE THESE TO YOUR ACTUAL NAMES ----
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatestoreaish123"
    container_name       = "terraform-state"     # must match container name exactly
   
    # -------------------------------------------
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      # Pin to a stable version to avoid unexpected regressions.
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
