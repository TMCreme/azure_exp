terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}


resource "azurerm_resource_group" "mainresourcegrp" {
  name     = "${var.prefix}-resources"
  location = "West Europe"
}

resource "azurerm_public_ip" "staticpublicip" {
  name                = "acceptanceTestPublicIp1"
  resource_group_name = azurerm_resource_group.mainresourcegrp.name
  location            = azurerm_resource_group.mainresourcegrp.location
  allocation_method   = "Static"

}

resource "azurerm_virtual_network" "mainvn" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.mainresourcegrp.location
  resource_group_name = azurerm_resource_group.mainresourcegrp.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.mainresourcegrp.name
  virtual_network_name = azurerm_virtual_network.mainvn.name
  address_prefixes     = ["10.0.0.0/16"]
}

resource "azurerm_network_interface" "mainnic" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.mainresourcegrp.location
  resource_group_name = azurerm_resource_group.mainresourcegrp.name


  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.staticpublicip.id
  }
}

resource "azurerm_network_security_group" "mainsg" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.mainresourcegrp.location
  resource_group_name = azurerm_resource_group.mainresourcegrp.name

  security_rule {
    name                       = "NormalHTTP"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Backend82"
    priority                   = 4095
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "82"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "staging"
  }

}

resource "azurerm_network_interface_security_group_association" "nic_to_sg" {
  network_interface_id      = azurerm_network_interface.mainnic.id
  network_security_group_id = azurerm_network_security_group.mainsg.id
}

resource "azurerm_virtual_machine" "mainvm" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.mainresourcegrp.location
  resource_group_name   = azurerm_resource_group.mainresourcegrp.name
  network_interface_ids = [azurerm_network_interface.mainnic.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = var.computer_name
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = file("./app/server_start.sh")
  }
  os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
    path     = "/home/${var.admin_username}/.ssh/authorized_keys"
    key_data = file("./automation/azuretestpem.pub")
  }
  }

  tags = {
    environment = "staging"
  }
}
