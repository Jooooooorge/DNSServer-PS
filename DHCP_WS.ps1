#********************************************************************************************************************************
# Script para automatizar la creación de un servidor DHCP personalizable

# Instalar el rol DHCP (Asegurarse que la IP sea Estatica)
Install-WindowsFeature -Name DHCP -IncludeManagementTools


# Crear ambito
Add-Dhcpserverv4Scope  # Este ya nos solicita los datos para configurar el servidor




