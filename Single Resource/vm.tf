## Windows VM Creation Block ##

resource "azurerm_windows_virtual_machine" "terraform_vm" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.terraform-training-rg.name
  location            = azurerm_resource_group.terraform-training-rg.location
  size                = "Standard_D2s_v3"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.nic-cdp-dl.id
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
  tags = var.tags
}

resource "azurerm_managed_disk" "terraform_vm_datadisk" {
  name                 = "terraformvm-dd"
  location             = azurerm_resource_group.terraform-training-rg.location
  resource_group_name  = azurerm_resource_group.terraform-training-rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "50"
  tags                 = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "terraform_vm_dd_attach" {
  managed_disk_id    = azurerm_managed_disk.terraform_vm_datadisk.id
  virtual_machine_id = azurerm_windows_virtual_machine.terraform_vm.id
  lun                = "0"
  caching            = "ReadWrite"
}

## Linux VM Creation Block ##

resource "azurerm_linux_virtual_machine" "linuxvm" {
  name                = var.linux_vm_name
  resource_group_name = azurerm_resource_group.terraform-training-rg.name
  location            = azurerm_resource_group.terraform-training-rg.location
  size                = "Standard_D2s_v3"
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.nic-cdp-dl-secondary.id
  ]

  admin_ssh_key {
    username   = var.admin_username
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
}