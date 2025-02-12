#************************************************************************************************
# SCRIPT para la creación de un servidor DNS en Ubuntu Server
# Instalación de BIND9

sudo -i
sudo apt update && sudo apt upgrade -y
sudo apt install net-tools -y
sudo apt install bind9 bind9utils bind9doc -y
sudo apt install dnsutils 

# Crear la carptea donde se guardaran las zonas
sudo mkdir /etc/bind/zones

# Nos dirigimos a la carpeta donde se encuentra lo que descargamos
cd /etc/bind/

# Sobreescribir el archivo name.conf.options
sudo nano /etc/bind/named.conf.options
# El contenido debe ser:
# acl LAN {
#     192.168.0.0/24;
# };
#
# options {
#     directory "/var/cache/bind";
#     allow-query { localhost; LAN; };
#     forwarders {
#         8.8.8.8;  # Usamos el DNS de Google como Forwarder
#     };
#     recursion yes;  # Permite consultas recursivas
#     listen-on-v6 { any; };
# };


# Sobreescribir el archivo named.conf.local
sudo nano /etc/bind/named.conf.local
# El contenido debe ser:
# zone "misitio.com" IN {
#     type master;
#     file "/etc/bind/zones/misitio.com";
# };
#
# zone "0.162.198.in-addr.arpa" IN {
#     type master;
#     file "/etc/bind/zones/misitio.com.rev";
# };


# Nos dirigimos a la carpeta de zonas
cd /etc/bind/zones

# Copíamos el archivo db.local para crear la zona
sudo cp /etc/bind/db.local /etc/bind/zones/misitio.com

# Editar el archivo de la zona para el dominio
sudo nano /etc/bind/zones/misitio.com
# El contenido debe ser:
# $TTL    604800
# @       IN      SOA     misitio.com. root.misitio.com. (
#                             3         ; Serial
#                         604800         ; Refresh
#                         86400         ; Retry
#                         2419200        ; Expire
#                         604800 )       ; Negative Cache TTL
#
# @       IN      NS      ns.misitio.com.
# @       IN      A       192.168.0.199
# ns      IN      A       192.168.0.199

# Crear el archivo de la zona inversa
sudo nano /etc/bind/zones/misitio.com.rev
# El contenido debe ser:
# $TTL    604800
# @       IN      SOA     misitio.com. root.misitio.com. (
#                             3         ; Serial
#                         604800         ; Refresh
#                         86400         ; Retry
#                         2419200        ; Expire
#                         604800 )       ; Negative Cache TTL
#
# @       IN      NS      ns.misitio.com.
# 199     IN      PTR     misitio.com.

# Reiniciar el servicio para reflejar la edición anterior
sudo systemctl enable bind9
sudo systemctl restart bind9

# Permitir el trafico DNS en el servidor
sudo ufw allow 53
sudo ufw reload

# Resetear el servicio