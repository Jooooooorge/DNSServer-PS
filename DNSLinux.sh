#************************************************************************************************
# SCRIPT para la creación de un servidor DNS en Ubuntu Server
# Instalación de BIND9
sudo apt install net-tools -y
sudo apt install bind9 bind9utils -y
sudo apt install dnsutils 

# Crear la carptea donde se guardaran las zonas
sudo mkdir /etc/bind/zones

# Nos dirigimos a la carpeta donde se encuentra lo que descargamos
cd /etc/bind/

# Sobreescribir el archivo named.conf.options
sudo bash -c 'cat <<EOF > /etc/bind/named.conf.options
acl LAN {
    192.168.0.0/24;
};

options {
    directory "/var/cache/bind";
    allow-query { localhost; LAN; };
    forwarders {
        8.8.8.8;  # Usamos el DNS de Google como Forwarder
    };
    recursion yes;  # Permite consultas recursivas
    listen-on-v6 { any; };
};
EOF'

# Sobreescribir el archivo named.conf.local
sudo bash -c 'cat <<EOF > /etc/bind/named.conf.local
zone "misitio.com" IN {
    type master;
    file "/etc/bind/zones/misitio.com";
};

zone "0.162.198.in-addr.arpa" IN {
    type master;
    file "/etc/bind/zones/misitio.com.rev";
};
EOF'

# Nos dirigimos a la carpeta de zonas
cd /etc/bind/zones

# Copíamos el archivo db.local para crear la zona
sudo cp /etc/bind/db.local /etc/bind/zones/misitio.com

# Crear el archivo de la zona para el dominio
sudo bash -c 'cat <<EOF > /etc/bind/zones/misitio.com
\$TTL    604800
@       IN      SOA     misitio.com. root.misitio.com. (
                        3         ; Serial
                    604800         ; Refresh
                    86400         ; Retry
                    2419200        ; Expire
                    604800 )       ; Negative Cache TTL

@       IN      NS      ns.misitio.com.
@       IN      A       192.168.0.199
ns      IN      A       192.168.0.199
EOF'

# Crear el archivo de la zona inversa
sudo bash -c 'cat <<EOF > /etc/bind/zones/misitio.com.rev
\$TTL    604800
@       IN      SOA     misitio.com. root.misitio.com. (
                        3         ; Serial
                    604800         ; Refresh
                    86400         ; Retry
                    2419200        ; Expire
                    604800 )       ; Negative Cache TTL

@       IN      NS      ns.misitio.com.
199     IN      PTR     misitio.com.
EOF'


# Reiniciar el servicio para reflejar la edición anterior
sudo systemctl enable bind9
sudo systemctl restart bind9

# Permitir el trafico DNS en el servidor
sudo ufw allow 53
sudo ufw reload
