# Terraform variables de configuracion global

variable "resource_group_name" {
  default = "rg-kube"
}

variable "location_name" {
  default = "uksouth"
}

variable "storage_account" {
  type = string
  description = "Nombre para la storage account"
  default = "stkube"
}

variable "public_key_path" {
  type = string
  description = "Ruta para la clave pública de acceso a las instancias"
  default = "~/.ssh/id_rsa.pub" 
}

variable "ssh_user" {
  type = string
  description = "Usuario para hacer ssh"
  default = "ansible"
}

variable "vm_size_master_nfs" {
  type = string
  description = "Tamaño de VM master/nfs"
  default = "Standard_D2_v2" # 7 GB, 2 CPU 
}

variable "vm_size_workers" {
  type = string
  description = "Tamaño VMs de los workers"
  default = "Standard_D1_v2" # 3.5 GB, 1 CPU 
}

variable "vms_master_nfs" {
  type = list(string)
  description = "Listado de VMs de tipo master/nfs"
  default = ["master", "nfs"]
}

variable "vms_workers" {
  type = list(string)
  description = "Listado de VMs de tipo workers"
  default = ["worker01", "worker02"]
}

variable "environment_var" {
  type = string
  description = "tipo de entorno de despliegue"
  default = "PREPROD"
}

variable "network_name" {
  type = string
  description = "az virtual network name"
  default = "kubenet"
}

variable "sub_network_name" {
  type = string
  description = "az virtual subnetwork name"
  default = "kubesubnet"
}

variable "network_cidr" {
  type = string
  description = "az virtual network cidr"
  default = "10.0.0.0/16"
}

variable "sub_network_cidr" {
  type = string
  description = "az virtual subnetwork cidr"
  default = "10.0.1.0/24"
}
