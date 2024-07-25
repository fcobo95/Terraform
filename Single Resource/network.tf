locals {
  address_space = "10.1.0.0/16"
  subnets = [
    {
      name           = "cdp-dl-subnet"
      address_prefix = "10.1.1.0/24"
    },
    {
      name           = "cdp-cdf-subnet"
      address_prefix = "10.1.2.0/24"
    }
  ]
  nic_name = "nic-cdp-dl"
  nic_name_scndr = "nic-cdp-dl-secondary"
  nic_cdp_pip_scndr = "nic-cdp-dl"
}

resource "azurerm_virtual_network" "cdp_vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.terraform_resource_group
  address_space       = [local.address_space]
  tags = var.tags
  depends_on = [
    azurerm_resource_group.terraform-training-rg
  ]
}

resource "azurerm_subnet" "cdp-dl-subnet" {
  name                 = local.subnets[0].name
  resource_group_name  = var.terraform_resource_group
  virtual_network_name = var.vnet_name
  address_prefixes     = [local.subnets[0].address_prefix]
  depends_on = [
    azurerm_virtual_network.cdp_vnet
  ]
}

resource "azurerm_subnet" "cdp-cdf-subnet" {
  name                 = local.subnets[1].name
  resource_group_name  = var.terraform_resource_group
  virtual_network_name = var.vnet_name
  address_prefixes     = [local.subnets[1].address_prefix]
  depends_on = [
    azurerm_virtual_network.cdp_vnet
  ]
}

resource "azurerm_network_interface" "nic-cdp-dl" {
  name                = local.nic_name
  location            = var.location
  resource_group_name = var.terraform_resource_group
  tags = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = tolist(azurerm_virtual_network.cdp_vnet.subnet)[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.nic-cdp-pip.id
  }

  depends_on = [
    azurerm_virtual_network.cdp_vnet
  ]
}

resource "azurerm_network_interface" "nic-cdp-dl-secondary" {
  name                = local.nic_name_scndr
  location            = var.location
  resource_group_name = var.terraform_resource_group
  tags = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = tolist(azurerm_virtual_network.cdp_vnet.subnet)[1].id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_virtual_network.cdp_vnet
  ]
}

resource "azurerm_public_ip" "nic-cdp-pip" {
  name                = var.nic_cdp_pip
  resource_group_name = var.terraform_resource_group
  location            = var.location
  allocation_method   = "Static"
  tags = var.tags
  depends_on = [
    azurerm_resource_group.terraform-training-rg
  ]
}

resource "azurerm_network_security_group" "nsg-cdp-dl-subnet" {
  name                = var.nsg_cdp_dl
  resource_group_name = var.terraform_resource_group
  location            = var.location
  tags = var.tags

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 22
    source_address_prefixes    = [local.subnets[0].address_prefix, local.subnets[1].address_prefix]
    destination_address_prefix = local.subnets[0].address_prefix
  }

  security_rule {
    name                       = "rdp"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 3389
    source_address_prefixes    = [local.subnets[0].address_prefix, local.subnets[1].address_prefix, "190.113.101.0/24"]
    destination_address_prefix = local.subnets[0].address_prefix
  }

  security_rule {
    name                       = "https"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 443
    source_address_prefixes    = [local.subnets[0].address_prefix, local.subnets[1].address_prefix]
    destination_address_prefix = local.subnets[0].address_prefix
  }

  security_rule {
    name                       = "mgmt"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 9443
    source_address_prefixes    = [local.subnets[0].address_prefix, local.subnets[1].address_prefix]
    destination_address_prefix = local.subnets[0].address_prefix
  }

  security_rule {
    name                       = "common-udp"
    priority                   = 104
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "0-65535"
    source_address_prefixes    = [local.subnets[0].address_prefix, local.subnets[1].address_prefix]
    destination_address_prefix = local.subnets[0].address_prefix
  }

  depends_on = [azurerm_resource_group.terraform-training-rg]

}

resource "azurerm_subnet_network_security_group_association" "cdp-dl-subnet-nsg-association" {
  subnet_id                 = azurerm_subnet.cdp-dl-subnet.id
  network_security_group_id = azurerm_network_security_group.nsg-cdp-dl-subnet.id
  depends_on                = [azurerm_subnet.cdp-dl-subnet]
}

output "subnets" {
  value = azurerm_virtual_network.cdp_vnet.subnet
}
