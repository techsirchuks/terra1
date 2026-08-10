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
  subscription_id = var.sub-id
}


#Here's our resource group
resource "azurerm_resource_group" "terra1" {
  name     = var.terra-rg
  location = var.location
}

#Here's our vnet
resource "azurerm_virtual_network" "terra1-vnet" {
  name                = var.vnet-name
  location            = var.location
  resource_group_name = var.terra-rg
  address_space       = var.vnet-address
}

#Here's our subnet
resource "azurerm_subnet" "terra1-subnet" {
  name                 = var.snet-name
  resource_group_name  = var.terra-rg 
  virtual_network_name = var.vnet-name 
  address_prefixes     = var.snet-address 
}

#here is our NSG
resource "azurerm_network_security_group" "frontend-nsg" {
  name                = "frontend-nsg"
  location            = var.location 
  resource_group_name = var.terra-rg
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
  resource_group_name         = var.terra-rg
  network_security_group_name = azurerm_network_security_group.frontend-nsg.name
}

#NSG rule for port 443
resource "azurerm_network_security_rule" "allow-https" {
  name                        = "allow-https"
  priority                    = "200"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.terra-rg
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
  resource_group_name         = var.terra-rg
  network_security_group_name = azurerm_network_security_group.frontend-nsg.name
}

#NSG for allowing port 80
resource "azurerm_network_security_rule" "deny-all" {
  name                        = "deny-all"
  priority                    = "4096"
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.terra-rg
  network_security_group_name = azurerm_network_security_group.frontend-nsg.name
}

#Here's our Public IP
resource "azurerm_public_ip" "terra1-ip" {
  name                = "terra1-ip"
  resource_group_name = var.terra-rg
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

#Network INterface card (NIC)
resource "azurerm_network_interface" "terra1-nic" {
  name                = "terra1-nic"
  location            = var.location
  resource_group_name = var.terra-rg
  ip_configuration {
    name                          = "terra-ip"
    subnet_id                     = azurerm_subnet.terra1-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.terra1-ip.id
  }
}

#Let's link our NIC with our NSG
resource "azurerm_network_interface_security_group_association" "terra1-nic-asso" {
  network_interface_id      = azurerm_network_interface.terra1-nic.id
  network_security_group_id = azurerm_network_security_group.frontend-nsg.id
}

#Here's our Linux VM
resource "azurerm_linux_virtual_machine" "terra1-vm" {
  name                = "terra1-vm"
  resource_group_name = var.terra-rg
  location            = var.location
  size                = "Standard_B2ts_v2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.terra1-nic.id
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "Ubuntu-24_04-LTS"
    sku       = "server"
    version   = "latest"
  }
}