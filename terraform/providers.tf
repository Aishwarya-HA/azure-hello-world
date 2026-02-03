terraform {
  required_version = ">= 1.6.0"

  # 🔐 Remote state in Azure Storage (adjust to your real names)
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatestoreaish123"
    container_name       = "terraform-state"
    key                  = "azure-hello-world.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.103.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.10"
    }
  }
}

provider "azurerm" {
  features {}

  # ✅ Use federated identity from GitHub Actions
  use_oidc = true

  # Optional (omit when exporting ARM_* in the workflow)
  # subscription_id = var.subscription_id
  # tenant_id       = var.tenant_id
  # client_id       = var.client_id
}
