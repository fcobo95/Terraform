resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.address_space]
  tags                = var.tags
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
  name                 = "${each.key}-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [each.value]
  service_endpoints = [ "Microsoft.Sql", "Microsoft.Storage", "Microsoft.KeyVault" ]
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}
