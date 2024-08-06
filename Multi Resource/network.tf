###########################################
# Azure Virtual Network Creation + Sunets #
###########################################
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.address_space]
  tags                = var.tags
  depends_on = [
    azurerm_resource_group.multi-resource-rg-tf
  ]
}

resource "azurerm_subnet" "mgmt-subnet" {
  name                 = "mgmt"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = ["10.101.0.0/24"]
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

locals {
  /*
    cidrsubnet(prefix, newbits, netnum)

    cidrsubnet("10.101.0.0/16", 24 - 16, 1)
    cidrsubnet("10.101.0.0/16"), 8, 1)

    cidrsubnet(16, 8, 1)
    prefix = 10.101.1.0/24
    newbits= 16 (prefix /16) + 8 = 24
    netnum = 1
    subnet 10.101.1.0/24
    */
  cdp_subnets = {
    cdp-dl = cidrsubnet(var.address_space, 8, 1)
    cdf    = cidrsubnet(var.address_space, 8, 2)
    cml    = cidrsubnet(var.address_space, 8, 3)
    cde    = cidrsubnet(var.address_space, 8, 4)
    cod    = cidrsubnet(var.address_space, 8, 5)
    dh     = cidrsubnet(var.address_space, 8, 6)
  }
}

resource "azurerm_subnet" "subnets" {
  for_each             = local.cdp_subnets
  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [each.value]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage", "Microsoft.KeyVault"]
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

resource "azurerm_network_security_group" "nsg-vms" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name

security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = [var.address_space, "190.113.101.0/24"]
    destination_address_prefix = var.address_space
  }
  security_rule {
    name                       = "https"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = [var.address_space]
    destination_address_prefix = var.address_space
  }
  security_rule {
    name                       = "mgmt"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9443"
    source_address_prefixes    = [var.address_space]
    destination_address_prefix = var.address_space
  }
  security_rule {
    name                       = "comm-tcp"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "0-65535"
    source_address_prefix      = var.address_space
    destination_address_prefix = var.address_space
  }
  security_rule {
    name                       = "comm-udp"
    priority                   = 104
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "0-65535"
    source_address_prefix      = var.address_space
    destination_address_prefix = var.address_space
  }
  security_rule {
    name                       = "icmp"
    priority                   = 105
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = [var.address_space]
    destination_address_prefix = var.address_space
  }

  security_rule {
    name                       = "rdp"
    priority                   = 106
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefixes    = [var.address_space, "190.113.101.0/24"]
    destination_address_prefix = var.address_space
  }

}

resource "azurerm_subnet_network_security_group_association" "nsg-association" {
  for_each                  = local.cdp_subnets
  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg-vms.id

  depends_on = [
    azurerm_network_security_group.nsg-vms
  ]
}

###########################################
# Azure Windows Virtual Machine Resources #
###########################################



resource "azurerm_public_ip" "windows-public-ips" {
  for_each            = local.cdp_subnets
  name                = "${each.key}-windows-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  tags                = var.tags

  depends_on = [
    azurerm_resource_group.multi-resource-rg-tf
  ]
}

resource "azurerm_network_interface" "windows-network-interfaces" {
  for_each            = local.cdp_subnets
  name                = "${azurerm_subnet.subnets[each.key].name}-win"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnets[each.key].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.windows-public-ips[each.key].id
  }

  depends_on = [
    azurerm_resource_group.multi-resource-rg-tf,
    azurerm_public_ip.windows-public-ips
  ]
}

###########################################
# Azure Linux Virtual Machine Resources   #
###########################################

resource "azurerm_public_ip" "linux-public-ips" {
  for_each            = local.cdp_subnets
  name                = "${each.key}-linux-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  tags                = var.tags

  depends_on = [
    azurerm_resource_group.multi-resource-rg-tf
  ]
}

resource "azurerm_network_interface" "linux-network-interfaces" {
  for_each            = local.cdp_subnets
  name                = "${azurerm_subnet.subnets[each.key].name}-linux"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnets[each.key].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.linux-public-ips[each.key].id
  }

  depends_on = [
    azurerm_resource_group.multi-resource-rg-tf,
    azurerm_subnet.subnets,
    azurerm_public_ip.linux-public-ips
  ]
}
