# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  subscription_id = "765266c6-9a23-4638-af32-dd1e32613047"
}

resource "azurerm_public_ip" "tp4" {
  name                = "publicanis"
  location            = "francecentral"
  resource_group_name = data.azurerm_resource_group.tp4.name
  allocation_method   = "Dynamic"
}


resource "azurerm_network_interface" "tp4" {
  name                = "devops-20210267"
  location            = data.azurerm_resource_group.tp4.location
  resource_group_name = data.azurerm_resource_group.tp4.name

  ip_configuration {
    name                          = "testConfiguration"
    subnet_id                     = data.azurerm_subnet.tp4.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tp4.id
  }
}

resource "tls_private_key" "rsa-4096-example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}



resource "azurerm_linux_virtual_machine" "tp4" {
  name                = "devops-20210267"
  resource_group_name = data.azurerm_resource_group.tp4.name
  location            = "francecentral"
  size                = "Standard_D2s_v3"
  admin_username      = "devops"

  network_interface_ids = [
    azurerm_network_interface.tp4.id,
  ]

  admin_ssh_key {
    username   = "devops"
    public_key = tls_private_key.rsa-4096-example.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

