locals {
  registration_token = azurerm_virtual_desktop_host_pool_registration_info.avd_token
}


data "azurerm_subnet" "onlinepoolsubnet01" {
  name                 = var.onlinepoolsubnet01
  virtual_network_name = azurerm_virtual_network.ffionlinepoolnet.name
  resource_group_name  = azurerm_resource_group.ffionline.name
  depends_on = [ azurerm_subnet.onlinepoolsubnet01 ]
}


resource "azurerm_resource_group" "rg" {
  provider = azurerm
  name     = var.rg
  location = var.deploy_location
}

resource "azurerm_network_interface" "FFIpool_nic" {
  provider            = azurerm
  count               = var.rdsh_count
  name                = "${var.prefix}-${count.index + 1}-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "nic${count.index + 1}_config"
    subnet_id                     = data.azurerm_subnet.onlinepoolsubnet01.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_resource_group.rg,
    azurerm_virtual_desktop_host_pool.ffihostpool01,
    azurerm_virtual_network_peering.tilaad
  ]
}

resource "azurerm_windows_virtual_machine" "FFIVm" {
  provider              = azurerm
  count                 = var.rdsh_count
  name                  = "${var.prefix}-${count.index + 1}"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = var.vm_size
  network_interface_ids = ["${azurerm_network_interface.FFIpool_nic.*.id[count.index]}"]

  provision_vm_agent    = true
  admin_username        = var.local_admin_username
  admin_password        = random_password.pol3passord.result


  os_disk {
    name                 = "${lower(var.prefix)}-${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  identity {
    type = "SystemAssigned"
  }

  source_image_reference {
    publisher = "microsoftwindowsdesktop"
    offer     = "office-365"
    sku       = "win11-21h2-avd-m365"
    version   = "latest"

  }


/*source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "20h2-evd"
    version   = "latest"
   }
   */
   depends_on = [
    azurerm_resource_group.rg,
    azurerm_network_interface.FFIpool_nic
 ]

}

resource "azurerm_virtual_machine_extension" "vmext_dsc" {
  count                      = var.rdsh_count
  name                       = "${var.prefix}${count.index + 1}-avd_dsc"
  virtual_machine_id         = azurerm_windows_virtual_machine.FFIVm.*.id[count.index]
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true

  settings = <<-SETTINGS
    {
      "modulesUrl": "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_09-08-2022.zip",
      "configurationFunction": "Configuration.ps1\\AddSessionHost",
      "properties": {
        "HostPoolName":"${azurerm_virtual_desktop_host_pool.ffihostpool01.name}"
      }
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "properties": {
      "registrationInfoToken": "${local.registration_token.token}"
    }
  }
PROTECTED_SETTINGS

  depends_on = [
    azurerm_virtual_desktop_host_pool.ffihostpool01
  ]
}
resource "azurerm_virtual_machine_extension" "AADLoginForWindows" {
  count                      = var.rdsh_count
  name                       = "AADLoginForWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.FFIVm.*.id[count.index]
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "2.0"
  auto_upgrade_minor_version = false



}

  resource "random_password" "pol3passord" {
  length  = 20
  special = true
}