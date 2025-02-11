#******************************************************************************************
# DNSServer
<# Este programa realiza levanta de manera automatica un servidor DNS
   para Windows Server, el programa le solicita al usuario una dirección IP
   la valida y solicita el nombre del dominio. 
#>
# Función para validar la dirección IP con expresión regular
function Validate-IP {
    param([string]$IP)
    # Regex para validar una dirección IP IPv4
    $regex = '^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    return $IP -match $regex
}
# Asegurarse de que el servicio DNS no está instalado
try {
    Uninstall-WindowsFeature -Name DNS -ErrorAction Stop
    Write-Host "[INFO] El rol DNS fue desinstalado exitosamente."
} catch {
    Write-Host "[INFO] El rol DNS no estaba instalado o no se pudo desinstalar."
}




# Instalación del rol DNS
Install-WindowsFeature -Name DNS -IncludeManagementTools
Write-Host "[INFO] Rol DNS instalado correctamente."

# Reiniciar el servicio DNS para asegurar que esté activo
Restart-Service DNS

# Pedir al usuario que introduzca la dirección IP manualmente
do {
    $serverIP = Read-Host "Introduce la dirección IP que deseas asignar al servidor (ejemplo: 192.168.1.10)"
    
    # Validar la IP usando la función
    if (-not (Validate-IP $serverIP)) {
        Write-Host "[ERROR] La dirección IP no es válida. Asegúrate de que esté en el formato correcto (ejemplo: 192.168.1.10)." -ForegroundColor Red
    }
} while (-not (Validate-IP $serverIP))

Write-Host "[INFO] Dirección IP asignada manualmente: $serverIP"

# Crear la zona primaria
try {
    Add-DnsServerPrimaryZone -Name "misitio.com" -ZoneFile "misitio.com.dns" -DynamicUpdate "NonSecureAndSecure"
    Write-Host "[INFO] Zona primaria 'misitio.com' creada correctamente."
} catch {
    Write-Host "[ERROR] No se pudo crear la zona primaria. Verifica si ya existe o revisa los permisos."
    Exit 1
}


# Crear el registro A para el dominio
try {
    Add-DnsServerResourceRecordA -ZoneName "misitio.com" -Name "@" -AllowUpdateAny -IPv4Address $serverIP
    Write-Host "[INFO] Registro A creado correctamente para 'misitio.com' con IP $serverIP."
} catch {
    Write-Host "[ERROR] No se pudo crear el registro A. Verifica si la zona existe y si la IP es válida."
    Exit 1
}

# Reiniciar el servicio DNS como paso final
Restart-Service DNS
Write-Host "[INFO] Configuración del servidor DNS completada con éxito."
