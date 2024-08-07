###########################################
# Azure Virtual Network Creation + Subnets#
###########################################
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.multi-resource-rg-tf.location
  resource_group_name = azurerm_resource_group.multi-resource-rg-tf.name
  address_space       = [var.address_space]
  tags                = var.tags
}

resource "azurerm_subnet" "mgmt-subnet" {
  name                 = "mgmt"
  resource_group_name  = azurerm_resource_group.multi-resource-rg-tf.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.101.0.0/24"]
}

resource "azurerm_subnet" "subnets" {
  count                = var.number_of_subnets
  name                 = "subnet${count.index}"
  resource_group_name  = azurerm_resource_group.multi-resource-rg-tf.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [cidrsubnet(var.address_space, 8, (count.index + 1))]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage", "Microsoft.KeyVault"]
}

resource "azurerm_network_security_group" "nsg-vms" {
  name                = var.nsg_name
  location            = azurerm_resource_group.multi-resource-rg-tf.location
  resource_group_name = azurerm_resource_group.multi-resource-rg-tf.name

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
  count                     = var.number_of_subnets
  subnet_id                 = azurerm_subnet.subnets[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg-vms.id
}

resource "azurerm_subnet_network_security_group_association" "nsg-association-mgmt" {
  subnet_id                 = azurerm_subnet.mgmt-subnet.id
  network_security_group_id = azurerm_network_security_group.nsg-vms.id
}

###########################################
# Azure Windows Virtual Machine Resources #
###########################################

resource "azurerm_public_ip" "windows-public-ips" {
  count               = var.number_of_vms
  name                = "windows-pip-${count.index}"
  resource_group_name = azurerm_resource_group.multi-resource-rg-tf.name
  location            = azurerm_resource_group.multi-resource-rg-tf.location
  allocation_method   = "Static"
  #zones               = ["1", "2", "3"]
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "windows-network-interfaces" {
  count               = var.number_of_vms
  name                = "win-nic-${count.index}"
  location            = azurerm_resource_group.multi-resource-rg-tf.location
  resource_group_name = azurerm_resource_group.multi-resource-rg-tf.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnets[count.index].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.windows-public-ips[count.index].id
  }
}

###########################################
# Azure Linux Virtual Machine Resources   #
###########################################

resource "azurerm_public_ip" "linux-public-ips" {
  count               = var.number_of_vms
  name                = "linux-pip-${count.index}"
  resource_group_name = azurerm_resource_group.multi-resource-rg-tf.name
  location            = azurerm_resource_group.multi-resource-rg-tf.location
  allocation_method   = "Static"
  tags                = var.tags
}

resource "azurerm_network_interface" "linux-network-interfaces" {
  count               = var.number_of_vms
  name                = "linux-nic-${count.index}"
  location            = azurerm_resource_group.multi-resource-rg-tf.location
  resource_group_name = azurerm_resource_group.multi-resource-rg-tf.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnets[count.index].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.linux-public-ips[count.index].id
  }
}
