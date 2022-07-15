# Terraform Security
#
# Primero crearemos el security group para el master y nfs
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group

resource "azurerm_network_security_group" "kubeSecGroupMasterNfs" {
    name                = "secgroup-${var.vms_master_nfs[count.index]}"
    count               = length(var.vms_master_nfs)
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "PREPROD"
    }
}

# Despues vinculamos el security group al NIC correspondiente
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association

resource "azurerm_network_interface_security_group_association" "kubeSecGroupAssociationMastarNfs" {
    count                     = length(var.vms_master_nfs)
    network_interface_id      = azurerm_network_interface.kubeNicMasterNfs[count.index].id
    network_security_group_id = azurerm_network_security_group.kubeSecGroupMasterNfs[count.index].id

}

# De igfual manera crearemos Security group para los workers
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group

resource "azurerm_network_security_group" "kubeSecGroupWorkers" {
    name                = "secgroup-${var.vms_workers[count.index]}"
    count               = length(var.vms_workers)
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "PREPROD"
    }
}

# Y por ultimo vinculamos el security group al NIC correspondiente
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association

resource "azurerm_network_interface_security_group_association" "kubeSecGroupAssociationWorkers" {
    count                     = length(var.vms_workers)
    network_interface_id      = azurerm_network_interface.kubeNicWorkers[count.index].id
    network_security_group_id = azurerm_network_security_group.kubeSecGroupWorkers[count.index].id

}
