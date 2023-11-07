terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.52.0"
    }
    azuread = {
      source = "hashicorp/azuread"
    }
  }
}

provider "azurerm" {
subscription_id = "98e0d1fb-ca80-42c8-a4fb-5e51f7315e90"
 client_id       = "cb1c1783-dc29-4ae8-9f18-53d44f56be33"
 client_secret   = "ATS8Q~Tm5cFqtO9YX4UZI0ld.p4nIt~_cbHf6di6"
tenant_id       = "df275205-c127-4645-b71b-85442a2b3266"
  features {}
}
