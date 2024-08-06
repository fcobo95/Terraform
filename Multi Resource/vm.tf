###########################################
# Azure Windows Virtual Machine Resources #
###########################################
resource "azurerm_windows_virtual_machine" "windows-vms" {
  count               = var.number_of_vms
  name                = "win-vm-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_sku
  admin_username      = var.owner
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.windows-network-interfaces[count.index].id
  ]
  availability_set_id = azurerm_availability_set.windows-vms-as.id

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.windows-network-interfaces,
    azurerm_resource_group.multi-resource-rg-tf
  ]
  tags = var.tags
}

resource "azurerm_managed_disk" "windows_vm_datadisks" {
  count                = var.number_of_vms
  name                 = "win-dd-${count.index}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "10"
  tags                 = var.tags

  depends_on = [
    azurerm_windows_virtual_machine.windows-vms
  ]
}

resource "azurerm_virtual_machine_data_disk_attachment" "windows_vm_datadisks" {
  count              = var.number_of_vms
  managed_disk_id    = azurerm_managed_disk.windows_vm_datadisks[count.index].id
  virtual_machine_id = azurerm_windows_virtual_machine.windows-vms[count.index].id
  lun                = "0"
  caching            = "ReadWrite"

  depends_on = [
    azurerm_windows_virtual_machine.windows-vms,
    azurerm_managed_disk.windows_vm_datadisks
  ]
}

resource "azurerm_availability_set" "windows-vms-as" {
  name                         = "windows-as"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  platform_fault_domain_count  = 3
  platform_update_domain_count = 3
  tags                         = var.tags

  depends_on = [
    azurerm_resource_group.multi-resource-rg-tf
  ]
}

###########################################
# Azure Linux Virtual Machine Resources   #
###########################################

resource "azurerm_linux_virtual_machine" "linux-vms" {
  count               = var.number_of_vms
  name                = "lnx-vm-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_D2s_v3"
  admin_username      = var.owner

  network_interface_ids = [
    azurerm_network_interface.linux-network-interfaces[count.index].id
  ]

  admin_ssh_key {
    username   = var.owner
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  tags = var.tags

  depends_on = [
    azurerm_resource_group.multi-resource-rg-tf
  ]
}

resource "azurerm_managed_disk" "linux_vm_datadisks" {
  count                = var.number_of_vms
  name                 = "lnx-dd-${count.index}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "10"
  tags                 = var.tags

  depends_on = [
    azurerm_linux_virtual_machine.linux-vms
  ]
}

resource "azurerm_virtual_machine_data_disk_attachment" "linux_vm_datadisks" {
  count              = var.number_of_vms
  managed_disk_id    = azurerm_managed_disk.linux_vm_datadisks[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.linux-vms[count.index].id
  lun                = "0"
  caching            = "ReadWrite"

  depends_on = [
    azurerm_linux_virtual_machine.linux-vms,
    azurerm_managed_disk.linux_vm_datadisks
  ]
}
