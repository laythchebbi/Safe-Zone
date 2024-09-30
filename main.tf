terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "03c8839b-c874-49a3-b3a9-ac0a2ef672d1"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

}

resource "azurerm_resource_group" "rg-test-01" {
  name     = "rg-test-01"
  location = "North Europe"
  tags = {
    environment = "dev"
    project     = "to-the-moon"
  }
}
resource "azurerm_resource_group" "rg-hub-01" {
  name     = "rg-hub-01"
  location = "North Europe"
  tags = {
    environment = "dev"
    project     = "to-the-moon"
    type        = "hub"
  }
}



resource "azurerm_network_security_group" "nsg-01" {
  name                = "nsg-01"
  resource_group_name = azurerm_resource_group.rg-test-01.name
  location            = azurerm_resource_group.rg-test-01.location
  tags                = azurerm_resource_group.rg-test-01.tags
  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_network_security_group" "nsg-02" {
  name                = "nsg-02"
  resource_group_name = azurerm_resource_group.rg-test-01.name
  location            = azurerm_resource_group.rg-test-01.location
  tags                = azurerm_resource_group.rg-test-01.tags
  security_rule {
    name                       = "RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_virtual_network" "vnet-01" {
  name                = "vnet-test-01"
  resource_group_name = azurerm_resource_group.rg-test-01.name
  location            = azurerm_resource_group.rg-test-01.location
  tags                = azurerm_resource_group.rg-test-01.tags
  address_space       = ["10.0.0.0/16"]
}
resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  address_prefixes     = ["10.0.0.0/24"]
  resource_group_name  = azurerm_resource_group.rg-test-01.name
  virtual_network_name = azurerm_virtual_network.vnet-01.name
}
resource "azurerm_subnet_network_security_group_association" "subnet_association-01" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.nsg-01.id
}
resource "azurerm_virtual_network" "vnet-hub-01" {
  name                = "vnet-hub-01"
  resource_group_name = azurerm_resource_group.rg-hub-01.name
  location            = azurerm_resource_group.rg-hub-01.location
  tags                = azurerm_resource_group.rg-hub-01.tags
  address_space       = ["10.1.0.0/16"]
}
resource "azurerm_subnet" "AzureFirewallSubnet" {
  name                 = "AzureFirewallSubnet"
  address_prefixes     = ["10.1.0.0/24"]
  resource_group_name  = azurerm_resource_group.rg-hub-01.name
  virtual_network_name = azurerm_virtual_network.vnet-hub-01.name

}
resource "azurerm_public_ip" "pip-fw" {
  name                = "pip-fw"
  resource_group_name = azurerm_resource_group.rg-hub-01.name
  location            = azurerm_resource_group.rg-hub-01.location
  tags                = azurerm_resource_group.rg-hub-01.tags
  allocation_method   = "Static"
}

resource "azurerm_firewall" "fw" {
  name                = "terrafirewall"
  resource_group_name = azurerm_resource_group.rg-hub-01.name
  location            = azurerm_resource_group.rg-hub-01.location
  tags                = azurerm_resource_group.rg-hub-01.tags
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "fw-ip-configurations"
    subnet_id            = azurerm_subnet.AzureFirewallSubnet.id
    public_ip_address_id = azurerm_public_ip.pip-fw.id
  }
}

resource "azurerm_subnet" "AzureBastionSubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg-hub-01.name
  virtual_network_name = azurerm_virtual_network.vnet-hub-01.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_public_ip" "pip-basion" {
  name                = "pip-bastion"
  resource_group_name = azurerm_resource_group.rg-hub-01.name
  location            = azurerm_resource_group.rg-hub-01.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion-host" {
  name                = "Bastion-Host"
  resource_group_name = azurerm_resource_group.rg-hub-01.name
  location            = azurerm_resource_group.rg-hub-01.location
  virtual_network_id  = azurerm_virtual_network.vnet-hub-01.id
  sku                 = "Developer"
}

resource "azurerm_public_ip" "pip01" {
  name                = "pip-01"
  resource_group_name = azurerm_resource_group.rg-test-01.name
  location            = azurerm_resource_group.rg-test-01.location
  tags                = azurerm_resource_group.rg-test-01.tags
  allocation_method   = "Static"
}
resource "azurerm_network_interface" "nic-01" {
  name                = "nic-01"
  resource_group_name = azurerm_resource_group.rg-test-01.name
  location            = azurerm_resource_group.rg-test-01.location
  tags                = azurerm_resource_group.rg-test-01.tags
  ip_configuration {
    name                          = "ip_config-01"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.0.5"
    public_ip_address_id          = azurerm_public_ip.pip01.id
  }
}

resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  address_prefixes     = ["10.0.1.0/24"]
  resource_group_name  = azurerm_resource_group.rg-test-01.name
  virtual_network_name = azurerm_virtual_network.vnet-01.name
}
resource "azurerm_subnet_network_security_group_association" "subnet_association-02" {
  subnet_id                 = azurerm_subnet.subnet2.id
  network_security_group_id = azurerm_network_security_group.nsg-02.id
}
resource "azurerm_public_ip" "pip02" {
  name                = "pip-02"
  resource_group_name = azurerm_resource_group.rg-test-01.name
  location            = azurerm_resource_group.rg-test-01.location
  tags                = azurerm_resource_group.rg-test-01.tags
  allocation_method   = "Static"
}
resource "azurerm_network_interface" "nic-02" {
  name                = "nic-02"
  resource_group_name = azurerm_resource_group.rg-test-01.name
  location            = azurerm_resource_group.rg-test-01.location
  tags                = azurerm_resource_group.rg-test-01.tags
  ip_configuration {
    name                          = "ip_config-02"
    subnet_id                     = azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.5"
    public_ip_address_id          = azurerm_public_ip.pip02.id
  }
}
resource "azurerm_virtual_machine" "vm-01" {
  name                  = "vm-linux-01"
  resource_group_name   = azurerm_resource_group.rg-test-01.name
  location              = azurerm_resource_group.rg-test-01.location
  tags                  = azurerm_resource_group.rg-test-01.tags
  network_interface_ids = [azurerm_network_interface.nic-01.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  storage_os_disk {
    name              = "OSDisk01"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "HunterXHunter"
    admin_username = "Kilwa"
    admin_password = "12Dreamspark@@"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}
resource "azurerm_windows_virtual_machine" "vm-02" {
  name                  = "vm-windows-01"
  resource_group_name   = azurerm_resource_group.rg-test-01.name
  location              = azurerm_resource_group.rg-test-01.location
  tags                  = azurerm_resource_group.rg-test-01.tags
  network_interface_ids = [azurerm_network_interface.nic-02.id]
  size                  = "Standard_E2s_v3"
  admin_username        = "Kilwa"
  admin_password        = "12Dreamspark@@"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }

}

resource "azurerm_virtual_network_peering" "hubtovnet" {
  name                      = "hubtovnet"
  resource_group_name       = azurerm_resource_group.rg-hub-01.name
  virtual_network_name      = azurerm_virtual_network.vnet-hub-01.name
  remote_virtual_network_id = azurerm_virtual_network.vnet-01.id
  allow_forwarded_traffic = "True"


}

resource "azurerm_virtual_network_peering" "vnettohub" {
  name                      = "vnettohub"
  resource_group_name       = azurerm_resource_group.rg-test-01.name
  virtual_network_name      = azurerm_virtual_network.vnet-01.name
  remote_virtual_network_id = azurerm_virtual_network.vnet-hub-01.id
}

resource "azurerm_log_analytics_workspace" "law" {
  name = "Law-terraform"
  resource_group_name = azurerm_resource_group.rg-hub-01.name
  location = azurerm_resource_group.rg-hub-01.location
  retention_in_days = 365
  sku = "Standard"
  tags = azurerm_resource_group.rg-hub-01.tags
}