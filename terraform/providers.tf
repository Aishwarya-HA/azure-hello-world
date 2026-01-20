
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      # Pin to a recent stable to avoid "inconsistent result after apply" flake
      # You can bump this minor version later with `terraform init -upgrade`.
      version = "~> 3.115.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
