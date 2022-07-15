
########### Terraform prerequisitos ##########
#
## En primer lugar es necesario crear un nuevo resource group que contendra todos los elementos de nuestro depliegue
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group

resource "azurerm_resource_group" "rg" {
    name     = var.resource_group_name
    location = var.location_name
    tags = {
        environment = var.environment_var
    }

}

# Despliegue del azurerm_storage_account 
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account

 resource "azurerm_storage_account" "st_account" {
   name                     = var.storage_account
   resource_group_name      = azurerm_resource_group.rg.name
   location                 = azurerm_resource_group.rg.location
   account_tier             = "Standard"
   account_replication_type = "LRS"

   tags = {
       environment = var.environment_var
   }

}

########### Terraform Networking ##########
#
# Crearemos la red (net) para las VMs
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network

resource "azurerm_virtual_network" "kubeNet" {
    name                = var.network_name
    address_space       = [var.network_cidr]
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    tags = {
        environment = var.environment_var
    }
}

# Despues la subred (subnet)
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet

resource "azurerm_subnet" "kubeSubnet" {
    name                   = var.sub_network_name
    resource_group_name    = azurerm_resource_group.rg.name
    virtual_network_name   = azurerm_virtual_network.kubeNet.name
    address_prefixes       = [var.sub_network_cidr]

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
    private_ip_address             = "10.0.1.${count.index + 11}"
    public_ip_address_id           = azurerm_public_ip.kubePublicIpMasterNfs[count.index].id
  }

    tags = {
        environment = var.environment_var
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
    private_ip_address             = "10.0.1.${count.index + 14}"
    public_ip_address_id           = azurerm_public_ip.kubePublicIpWorkers[count.index].id
  }

    tags = {
        environment = var.environment_var
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
        environment = var.environment_var
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
        environment = var.environment_var
    }

}

########### Terraform Maquinas virtuales ##########
#
# Creamos las máquinas virtuales para master y nfs
# el username, lo definimos como default var.ssh_user y la public key la extraemos de: ~/.ssh/id_rsa.pub
# La imagen de la maquina la seleccionamos de:
# https://azuremarketplace.microsoft.com/es-es/marketplace/apps/cognosys.centos-8-lvm?tab=Overview
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine

resource "azurerm_linux_virtual_machine" "kubeVMMasterNfs" {
    name                = "kubeVm-${var.vms_master_nfs[count.index]}"
    count               = length(var.vms_master_nfs)
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    size                = var.vm_size_master_nfs
    admin_username      = var.ssh_user
    network_interface_ids = [ azurerm_network_interface.kubeNicMasterNfs[count.index].id ]
    disable_password_authentication = true

    admin_ssh_key {
        username   = var.ssh_user
        public_key = file(var.public_key_path) 
    }

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    plan {
        name      = "centos-8-stream-free"
        product   = "centos-8-stream-free"
        publisher = "cognosys"
    }

    source_image_reference {
        publisher = "cognosys"
        offer     = "centos-8-stream-free"
        sku       = "centos-8-stream-free"
        version   = "22.03.28"
    }

    #boot_diagnostics {
      # storage_account_uri = azurerm_storage_account.stAccount.primary_blob_endpoint
    #}

    tags = {
        environment = var.environment_var
    }

}

# Despues creamos las máquinas virtuales para los workers

resource "azurerm_linux_virtual_machine" "kubeVMWorkers" {
    name                = "kubeVm-${var.vms_workers[count.index]}"
    count               = length(var.vms_workers)
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    size                = var.vm_size_workers
    admin_username      = var.ssh_user
    network_interface_ids = [ azurerm_network_interface.kubeNicWorkers[count.index].id ]
    disable_password_authentication = true

    admin_ssh_key {
        username   = var.ssh_user
        public_key = file(var.public_key_path)
    }

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    plan {
        name      = "centos-8-stream-free"
        product   = "centos-8-stream-free"
        publisher = "cognosys"
    }

    source_image_reference {
        publisher = "cognosys"
        offer     = "centos-8-stream-free"
        sku       = "centos-8-stream-free"
        version   = "22.03.28"
    }

    #boot_diagnostics {
    #    storage_account_uri = azurerm_storage_account.stAccount.primary_blob_endpoint
    #}

    tags = {
        environment = var.environment_var
    }

}

########### Terraform Security groups ##########
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
        environment = var.environment_var
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
        environment = var.environment_var
    }
}

# Y por ultimo vinculamos el security group al NIC correspondiente
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association

resource "azurerm_network_interface_security_group_association" "kubeSecGroupAssociationWorkers" {
    count                     = length(var.vms_workers)
    network_interface_id      = azurerm_network_interface.kubeNicWorkers[count.index].id
    network_security_group_id = azurerm_network_security_group.kubeSecGroupWorkers[count.index].id

}
