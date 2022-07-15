# Para iniciar el proceso de configuracion deberemos en primer lugar realizar el login en Azure:
# az login
# Despues listamos el rango de IPs publicas asignadas:
#
# az vm list-ip-addresses | grep "kubeVm"
# az vm list-ip-addresses | grep "20."
#
# Editamos el fichero de inventario hosts.yaml y incluimos las IPs de los nodos obtenidas:
# y por ultimo lanzamos la serie de playbooks a todos los nodos definidos:

echo 'start ansible deploy in Azure:'
cd ansible
ansible-playbook -i hosts.yaml 1_config_comun.yaml -K 
ansible-playbook -i hosts.yaml 2_config_nfs.yaml -K 
ansible-playbook -i hosts.yaml 3_config_comun_kube.yaml -K 
ansible-playbook -i hosts.yaml 4_config_master_worker.yaml -K 
ansible-playbook -i hosts.yaml 5_config_app.yaml -K

echo 'POD list:'
# comando para listar los pods
