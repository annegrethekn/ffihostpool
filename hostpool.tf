resource "azurerm_resource_group" "ffionline" {
  name     = var.rg
  location = var.deploy_location
}

resource "azurerm_virtual_desktop_host_pool" "ffihostpool01" {
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  name                  = var.Hostpoolname
  friendly_name         = "FFIpool"
  validate_environment  = true
  start_vm_on_connect   = true
  custom_rdp_properties = "targetisaadjoined:i:1;drivestoredirect:s:*;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:1;devicestoredirect:s:*;redirectcomports:i:1;redirectsmartcards:i:1;usbdevicestoredirect:s:*;enablecredsspsupport:i:1;redirectwebauthn:i:1;use multimon:i:1;"
  # custom_rdp_properties    = "audiocapturemode:i:1;audiomode:i:0;"
  description              = "Scripted host pool"
  type                     = "Pooled"
  maximum_sessions_allowed = 50
  load_balancer_type       = "BreadthFirst"

}

# Create AVD DAG
resource "azurerm_virtual_desktop_application_group" "desktoponline" {
  provider            = azurerm
  resource_group_name = azurerm_resource_group.rg.name
  host_pool_id        = azurerm_virtual_desktop_host_pool.ffihostpool01.id
  location            = azurerm_resource_group.rg.location
  type                = "Desktop"
  name                = "ffi-test-${var.prefix}-online"
  friendly_name       = "AVD Full Desktop"
  description         = "AVD Full Desktop"
  depends_on = [azurerm_virtual_desktop_host_pool.ffihostpool01,
                           azurerm_resource_group.rg]
}


#Create WVD workspace
resource "azurerm_virtual_desktop_workspace" "ffionline" {
  provider            = azurerm
  name                = "ffionline"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  friendly_name       = "ffiavd OnlineWorkspace"
  description         = "ffiavd OnlineWorkspace"

}

# Associate Workspace and DAG
resource "azurerm_virtual_desktop_workspace_application_group_association" "ffionline" {
  provider             = azurerm
  application_group_id = azurerm_virtual_desktop_application_group.desktoponline.id
  workspace_id         = azurerm_virtual_desktop_workspace.ffionline.id
       depends_on           = [azurerm_virtual_desktop_workspace.ffionline]
}


resource "azurerm_virtual_desktop_host_pool_registration_info" "avd_token" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.ffihostpool01.id
  expiration_date = var.rfc3339
}
