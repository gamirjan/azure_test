terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "stg"
    storage_account_name = "state123"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
  