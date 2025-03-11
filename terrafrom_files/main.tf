# Configure Azure Provider
provider "azurerm" {
  features {}
  subscription_id = "13a4df32-8add-46d8-85e8-6efbb2d7395e"
}

# Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "postgresql-vm-rg"
  location = "East US"  # Change this to your preferred region
}

# Create Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "postgresql-vnet"
  address_space       = ["10.0.0.0/16"]
  location           = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "postgresql-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create Public IP
resource "azurerm_public_ip" "public_ip" {
  name                = "postgresql-vm-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static" # Ensure allocation method is set to Static
  sku                 = "Standard" # Ensure SKU is set to Standard

  tags = {
    environment = "Production"
  }
}

# Create Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "postgresql-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # SSH access
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range         = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"  # In production, restrict this to your IP
    destination_address_prefix = "*"
  }

  # PostgreSQL access
  security_rule {
    name                       = "PostgreSQL"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range         = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "*"  # In production, restrict this to your IP
    destination_address_prefix = "*"
  }
}