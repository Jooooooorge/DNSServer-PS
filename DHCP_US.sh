#********************************************************************************************************************************
# Script para automatizar la creación de un servidor DHCP personalizable


# Actualizar e instalar paquetes necesarios
sudo apt update
sudo apt install -y net-tools
sudo apt install isc-dhcp-server

# Configuración de red estatica 
echo "network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: no
      addresses:
        - [192.168.1.10/24]
      gateway4: 192.168.1.254
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4" | sudo tee /etc/netplan/00-installer-config.yaml > /dev/null

# Aplicar cambios de red
sudo netplan apply  

# Realizar los siguientes cambios en los arhivos de configuración
# del server DHCP /etc/dhcp/dhcp.conf

echo "
    default-lease-time 43200;
    max-lease-time 86400;
    option subnet-masl 255.255.255.0;
    option broadcast-address 192.168.1.255;
    option domain-name "local.lan";
    authoritatvie;
    subet 192.168.1.0 netmask 255.255.255.0{
        range 192.168.1.20 192.168.1.30;
        option routers 192.168.1.254;
        option domain-name-servers 192.168.1.254; 
    } 
" | sudo tee /etc/dhcp/dhcp.conf > /dev/null

sudo systemctl start isc-dhcp-server