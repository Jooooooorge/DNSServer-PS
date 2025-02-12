#************************************************************************************************
# 
# Instalación de BIND9
# Herramienta empleada
sudo apt install bind9
sudo apt install dnsutils

cd /etc/bind/

echo"
    directory "/var/cache/bind"
    forwarders{
        8.8.8.8;
    }

    dnssec-validation auto;
    listen-on-v6 {} any; };
" > name.conf.options 

# Resetear el servicio
