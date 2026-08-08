terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.57.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "fb5254d0-da10-4428-ae41-85602fe2931c"
}


#Here's our resource group
resource "azurerm_resource_group" "terra1" {
  name     = "terra1"
  location = "southafricanorth"
}

#testing 