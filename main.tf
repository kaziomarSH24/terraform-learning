#Configuration Setup
terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "~> 3.0"
        }
    }
}

provider "azurerm" {
    features {}
}

#Resource Group (Central India)
resource "azurerm_resource_group" "my_rg" {
    name     = "my-first-terraform-rg"
    location = "Central India"
}

#Virtual Network
resource "azurerm_virtual_network" "my_vnet" {
    name                = "my-learning-network"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.my_rg.location
    resource_group_name = azurerm_resource_group.my_rg.name
}

# Subnet
resource "azurerm_subnet" "my_subnet" {
    name                 = "internal"
    resource_group_name  = azurerm_resource_group.my_rg.name
    virtual_network_name = azurerm_virtual_network.my_vnet.name
    address_prefixes     = ["10.0.1.0/24"]
}

#Public IP (Standard SKU)
resource "azurerm_public_ip" "my_public_ip" {
    name                = "my-vm-ip"
    resource_group_name = azurerm_resource_group.my_rg.name
    location            = azurerm_resource_group.my_rg.location
    allocation_method   = "Static"
    sku                 = "Standard"
}

#Network Security Group (NSG)
resource "azurerm_network_security_group" "my_nsg" {
    name                = "my-vm-nsg"
    location            = azurerm_resource_group.my_rg.location
    resource_group_name = azurerm_resource_group.my_rg.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTP"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

#Network Interface (NIC)
resource "azurerm_network_interface" "my_nic" {
    name                = "my-vm-nic"
    location            = azurerm_resource_group.my_rg.location
    resource_group_name = azurerm_resource_group.my_rg.name

    ip_configuration {
        name                          = "internal"
        subnet_id                     = azurerm_subnet.my_subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.my_public_ip.id
    }
}

#NIC and NSG Association
resource "azurerm_network_interface_security_group_association" "my_nic_nsg_assoc" {
    network_interface_id      = azurerm_network_interface.my_nic.id
    network_security_group_id = azurerm_network_security_group.my_nsg.id
}

#Virtual Machine (VM) - Using ARM64 Processor
resource "azurerm_linux_virtual_machine" "my_vm" {
    name                = "my-first-vm"
    resource_group_name = azurerm_resource_group.my_rg.name
    location            = azurerm_resource_group.my_rg.location
    
    size                = "Standard_B2ps_v2" 
    
    admin_username      = "azureuser"
    admin_password      = "HardPassword123!"
    disable_password_authentication = false

    network_interface_ids = [
        azurerm_network_interface.my_nic.id,
    ]

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts-arm64" 
        version   = "latest"
    }
}
