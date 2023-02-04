terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.41.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "fresh_tfstate"
    storage_account_name = "<your storrage account>"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {

  }
}

resource "azurerm_resource_group" "fresh_rg" {
  name     = "fresh-resources"
  location = "norwayeast" 
  tags = {
    environment = "fresh"
  }
}

resource "azurerm_resource_group" "NetworkWatcherRG" {
  name     = "NetworkWatcherRG"
  location = "norwayeast"
  tags = var.tags
}

resource "azurerm_virtual_network" "fresh_vn" {
  name                = "fresh_vn"
  location            = azurerm_resource_group.fresh_rg.location
  resource_group_name = azurerm_resource_group.fresh_rg.name
  address_space       = ["10.0.0.0/16"]
  tags = var.tags
}

resource "azurerm_network_watcher" "fresh_nw" {
  name                = "fresh_nw"
  location            = azurerm_resource_group.NetworkWatcherRG.location
  resource_group_name = azurerm_resource_group.NetworkWatcherRG.name
  tags = var.tags
}

resource "azurerm_subnet" "fresh_subnet" {
  name                 = "fresh_subnet"
  resource_group_name  = azurerm_resource_group.fresh_rg.name
  virtual_network_name = azurerm_virtual_network.fresh_vn.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "fresh_sg" {
  name                = "fresh_sg"
  location            = azurerm_resource_group.fresh_rg.location
  resource_group_name = azurerm_resource_group.fresh_rg.name
  tags = var.tags
}

resource "azurerm_network_security_rule" "fresh_network_security_rule_in" {
  name                        = "fresh_network_security_rule_in"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.fresh_rg.name
  network_security_group_name = azurerm_network_security_group.fresh_sg.name
}

resource "azurerm_network_security_rule" "fresh_network_security_rule_out" {
  name                        = "fresh_network_security_rule_out"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.fresh_rg.name
  network_security_group_name = azurerm_network_security_group.fresh_sg.name
}

resource "azurerm_subnet_network_security_group_association" "fresh_sga" {
  subnet_id                 = azurerm_subnet.fresh_subnet.id
  network_security_group_id = azurerm_network_security_group.fresh_sg.id
}