
data "azurerm_resource_group" "ffionline"{
  name = var.rg
   depends_on = [ azurerm_virtual_desktop_host_pool.ffihostpool01 ]
}

data "azurerm_resource_group" "Domeneresurs"{
   name = var.Domeneresurs
}

data "azurerm_virtual_network" "aadds-vnet-01"{
  name = "aadds-vnet-01"
resource_group_name = data.azurerm_resource_group.Domeneresurs.name
}

resource "azurerm_virtual_network" "ffionlinepoolnet" {
name                = var.ffionlinepoolnet
 location = data.azurerm_resource_group.ffionline.location
 resource_group_name = data.azurerm_resource_group.ffionline.name
 address_space       = ["192.168.0.0/16"]


depends_on = [
  data.azurerm_resource_group.ffionline
]
}

resource "azurerm_subnet" "onlinepoolsubnet01" {
  name                 = "onlinepoolsubnet01"
  address_prefixes = ["192.168.0.0/18"]
  virtual_network_name = azurerm_virtual_network.ffionlinepoolnet.name
  resource_group_name  = data.azurerm_resource_group.ffionline.name
}



data "azurerm_virtual_network" "aadds-vn-01" {
      name                = "aadds-vnet-01"
  resource_group_name = data.azurerm_resource_group.Domeneresurs.name
  }


resource "azurerm_virtual_network_peering" "tilaad" {
  name                      = var.tilaad
  resource_group_name       = data.azurerm_resource_group.Domeneresurs.name
  virtual_network_name      = data.azurerm_virtual_network.aadds-vnet-01.name
  remote_virtual_network_id = azurerm_virtual_network.ffionlinepoolnet.id
}
