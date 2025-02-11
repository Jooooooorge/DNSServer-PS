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

# Crear la zona primaria
try {
    Add-DnsServerPrimaryZone -Name "misitio.com" -ZoneFile "misitio.com.dns" -DynamicUpdate "NonSecureAndSecure"
    Write-Host "[INFO] Zona primaria 'misitio.com' creada correctamente."
} catch {
    Write-Host "[ERROR] No se pudo crear la zona primaria. Verifica si ya existe o revisa los permisos."
    Exit 1
}

# Obtener la dirección IP del servidor
$ipv4 = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -NotMatch "^169" }).IPAddress | Select-Object -First 1

if (-not $ipv4) {
    Write-Host "[ERROR] No se detectó una dirección IP válida. Configura una dirección estática antes de continuar."
    Exit 1
}

Write-Host "[INFO] Dirección IP detectada: $ipv4"

# Crear el registro A para el dominio
try {
    Add-DnsServerResourceRecordA -ZoneName "misitio.com" -Name "@" -AllowUpdateAny -IPv4Address $ipv4
    Write-Host "[INFO] Registro A creado correctamente para 'misitio.com' con IP $ipv4."
} catch {
    Write-Host "[ERROR] No se pudo crear el registro A. Verifica si la zona existe y si la IP es válida."
    Exit 1
}

# Reiniciar el servicio DNS como paso final
Restart-Service DNS
Write-Host "[INFO] Configuración del servidor DNS completada con éxito."
