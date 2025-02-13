#!/bin/bash
#************************************************************************************************
# SCRIPT para la creación de un servidor DNS en Ubuntu Server

# Actualizar e instalar paquetes necesarios
sudo apt update
sudo apt install -y net-tools bind9 bind9utils dnsutils

# Solicitar al usuario el dominio e IP
read -p "Ingresa el nombre del dominio: " dominio
read -p "Ingresa la dirección IP: " ip

# Configurar la IP a estática
sudo bash -c "cat <<EOF > /etc/netplan/00-installer-config.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: no
      addresses:
        - $ip/24
      gateway4: 192.168.0.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
EOF"

# Aplicar cambios de red
sudo netplan apply

# Crear la carpeta donde se guardarán las zonas
sudo mkdir -p /etc/bind/zones

# Preparar la IP invertida para la zona inversa
IFS='.' read -r seg1 seg2 seg3 seg4 <<< "$ip"
ipInvertida="${seg3}.${seg2}.${seg1}"

# Configurar named.conf.options
sudo bash -c "cat <<EOF > /etc/bind/named.conf.options
options {
    directory \"/var/cache/bind\";
    forwarders {
        8.8.8.8;
    };
    dnssec-validation auto;
    listen-on-v6 { any; };
};
EOF"

# Configurar named.conf.local
sudo bash -c "cat <<EOF > /etc/bind/named.conf.local
zone \"$dominio\" IN {
    type master;
    file \"/etc/bind/zones/$dominio\";
};

zone \"$ipInvertida.in-addr.arpa\" IN {
    type master;
    file \"/etc/bind/zones/$dominio.rev\";
};
EOF"

# Crear la zona directa
sudo bash -c "cat <<EOF > /etc/bind/zones/$dominio
\$TTL    604800
@       IN      SOA     $dominio. root.$dominio. (
                        1         ; Serial
                    604800         ; Refresh
                    86400         ; Retry
                    2419200        ; Expire
                    604800 )       ; Negative Cache TTL

@       IN      NS      ns.$dominio.
@       IN      A       $ip
ns      IN      A       $ip
www     IN      A       $ip
EOF"

# Crear la zona inversa
sudo bash -c "cat <<EOF > /etc/bind/zones/$dominio.rev
\$TTL    604800
@       IN      SOA     $dominio. root.$dominio. (
                        2         ; Serial
                    604800         ; Refresh
                    86400         ; Retry
                    2419200        ; Expire
                    604800 )       ; Negative Cache TTL

@       IN      NS      ns.$dominio.
$seg4     IN      PTR     $dominio.
EOF"

# Reiniciar el servicio BIND9
sudo systemctl restart bind9

# Permitir tráfico DNS
sudo ufw allow 53
sudo ufw reload
