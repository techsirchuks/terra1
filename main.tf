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

#Here's our vnet
resource "azurerm_virtual_network" "terra1-vnet" {
  name                = "terra1-vnet"
  location            = azurerm_resource_group.terra1.location
  resource_group_name = azurerm_resource_group.terra1.name
  address_space       = ["10.0.0.0/16"]
}

#Here's our subnet
resource "azurerm_subnet" "terra1-subnet" {
  name                 = "terra1-subnet"
  resource_group_name  = azurerm_resource_group.terra1.name
  virtual_network_name = azurerm_virtual_network.terra1-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

#here is our NSG
resource "azurerm_network_security_group" "frontend-nsg" {
  name                = "frontend-nsg"
  location            = azurerm_resource_group.terra1.location
  resource_group_name = azurerm_resource_group.terra1.name
}

#NSG for allowing port 80
resource "azurerm_network_security_rule" "allow-http" {
  name                        = "allow-http"
  priority                    = "100"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.terra1.name
  network_security_group_name = azurerm_network_security_group.frontend-nsg.name
}

#NSG for opening port 22
resource "azurerm_network_security_rule" "allow-ssh" {
  name                        = "allow-ssh"
  priority                    = "110"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.terra1.name
  network_security_group_name = azurerm_network_security_group.frontend-nsg.name
}
