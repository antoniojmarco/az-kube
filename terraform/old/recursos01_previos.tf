# En primer lugra es necesario crear un nuevo resorce group que contendra todos los elementos de nuestro depliegue
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group

resource "azurerm_resource_group" "rg" {
    name     = var.resource_group_name
    location = var.location_name
    tags = {
        environment = "PREPROD"
    }

}

#Despliegue del azurerm_storage_account 
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account

 resource "azurerm_storage_account" "st_account" {
   name                     = var.storage_account
   resource_group_name      = azurerm_resource_group.rg.name
   location                 = azurerm_resource_group.rg.location_name
   account_tier             = "Standard"
   account_replication_type = "LRS"

   tags = {
       environment = "PREPROD"
   }

}