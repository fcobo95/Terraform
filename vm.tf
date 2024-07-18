resource "azurerm_windows_virtual_machine" "terraform_vm" {
  name                = var.vm_name
  resource_group_name = var.terraform_resource_group
  location            = var.location
  size                = "Standard_D2s_v3"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.nic-cdp-dl.id,
    azurerm_network_interface.nic-cdp-dl-secondary.id
  ]

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
    azurerm_network_interface.nic-cdp-dl,
    azurerm_network_interface.nic-cdp-dl-secondary,
    azurerm_resource_group.terraform-training-rg
  ]
  tags = var.tags
}

resource "azurerm_managed_disk" "terraform_vm_datadisk" {
  name                 = "terraformvm-dd"
  location             = var.location
  resource_group_name  = var.terraform_resource_group
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "50"
  tags                 = var.tags
  depends_on = [
    azurerm_windows_virtual_machine.terraform_vm
  ]
}

resource "azurerm_virtual_machine_data_disk_attachment" "terraform_vm_dd_attach" {
  managed_disk_id    = azurerm_managed_disk.terraform_vm_datadisk.id
  virtual_machine_id = azurerm_windows_virtual_machine.terraform_vm.id
  lun                = "0"
  caching            = "ReadWrite"
  depends_on = [
    azurerm_managed_disk.terraform_vm_datadisk,
    azurerm_windows_virtual_machine.terraform_vm
  ]
}
