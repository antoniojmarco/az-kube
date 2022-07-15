# Pagina principal de terraform  debemos selecionar la version de terraform que queremos usar y elegir el cloud provider
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
# en este caso la version de 06-2022  mas reciente es la : 3.10.0
# https://registry.terraform.io/providers/hashicorp/azurerm/3.10.0
#
# Instacion del software de terraform:
# Nos autenticamos en terraform con la cuenta de github para acceder y decargamos la version acorde al S.O
# https://www.terraform.io/downloads.html
#
# en mi caso la version de S.O es fedora:
# sudo dnf install -y dnf-plugins-core
# sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
# sudo dnf -y install terraform
#
# Instacion del CLI de azure:
# https://learn.hashicorp.com/collections/terraform/azure-get-started
# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=dnf
# importamos el repositoty key:
# sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
# para Centos8 y RHEL8:
# sudo dnf install -y https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm
# instalamos el CLI:
# sudo dnf install azure-cli


echo 'start terraform deploy in Azure:'
cd terraform
terraform init
terraform plan -out=planx
terraform apply planx
cd ..
echo 'VM list:'
az vm list-ip-addresses
# en este punto se puede ver la lista de las VM's que deberiamos pasar al fichero de configuracion del inventario de ansible

