# Terraform Networking
#
# Primero crearemos la red (net) para las VMs
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network

resource "azurerm_virtual_network" "kubeNet" {
    name                = "kubernetesnet"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    tags = {
        environment = "PREPROD"
    }
}

# Despues la subred (subnet)
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet

resource "azurerm_subnet" "kubeSubnet" {
    name                   = "terraformsubnet"
    resource_group_name    = azurerm_resource_group.rg.name
    virtual_network_name   = azurerm_virtual_network.kubeNet.name
    address_prefixes       = ["10.0.1.0/24"]

}

# Acto seguido las interfaces de red (NICs) para el master y nfs 
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface

resource "azurerm_network_interface" "kubeNicMasterNfs" {
  name                = "nic-${var.vms_master_nfs[count.index]}" 
  count               = length(var.vms_master_nfs)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
    name                           = "kubeipconfiguration1"
    subnet_id                      = azurerm_subnet.kubeSubnet.id 
    private_ip_address_allocation  = "Static"
    private_ip_address             = "10.0.1.${count.index + 10}"
    public_ip_address_id           = azurerm_public_ip.kubePublicIpMasterNfs[count.index].id
  }

    tags = {
        environment = "PREPROD"
    }

}

# Continuamos con la creacion de los (NICs) para los workers

resource "azurerm_network_interface" "kubeNicWorkers" {
  name                = "nic-${var.vms_workers[count.index]}" 
  count               = length(var.vms_workers)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
    name                           = "kubeipconfiguration1"
    subnet_id                      = azurerm_subnet.kubeSubnet.id 
    private_ip_address_allocation  = "Static"
    private_ip_address             = "10.0.1.${count.index + 11}"
    public_ip_address_id           = azurerm_public_ip.kubePublicIpWorkers[count.index].id
  }

    tags = {
        environment = "PREPROD"
    }

}

# Ahora definimos la IP pública para el master y NFS
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip

resource "azurerm_public_ip" "kubePublicIpMasterNfs" {
  name                = "pubip-${var.vms_master_nfs[count.index]}"
  count               = length(var.vms_master_nfs)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"

    tags = {
        environment = "PREPROD"
    }

}

# Y por ultimo la Public IP para los workers

resource "azurerm_public_ip" "kubePublicIpWorkers" {
  name                = "pubip-${var.vms_workers[count.index]}"
  count               = length(var.vms_workers)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"

    tags = {
        environment = "PREPROD"
    }

}