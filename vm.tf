resource "azurerm_windows_virtual_machine" "terraform_vm" {
  name                = var.vm_name
  resource_group_name = var.terraform_resource_group
  location            = var.location
  size                = "Standard_D2S_v3"
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

  depends_on = [
    azurerm_network_interface.nic-cdp-dl,
    azurerm_resource_group.terraform-training-rg
  ]
}
