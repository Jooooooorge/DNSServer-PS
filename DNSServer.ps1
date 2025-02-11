# Asegurarse de que el servicio no está instalado
try {
    Uninstall-WindowsFeature -Name DNS -ErrorAction Stop
} catch {
    Write-Host "[INFO] El rol DNS no estaba instalado o no se pudo desinstalar."
}

# Instalación del rol DNS en el Administrador de Servicio
Install-WindowsFeature -Name DNS -IncludeManagementTools
Restart-Service DNS
# Crear la zona primaria
Add-DNSServerPrimaryZone -Name "misitio.com" -ZoneFile "misitio.com.dns" -DynamicUpdate "NonSecureAndSecure"

# Asignar la dirección IP del servidor al dominio
# Filtrar para obtener solo una dirección válida
$ipv4 = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -NotMatch "^169" }).IPAddress | Select-Object -First 1

if ($ipv4) {
    Write-Host "[INFO] Dirección IP detectada: $ipv4"
} else {
    Write-Host "[ERROR] No se pudo detectar una dirección IP válida."
    Exit 1
}

# Crear el host A/AAAA para resolver el nombre de dominio
Add-DNSServerResourceRecordA -ZoneName "misitio.com" -Name "@" -AllowUpdateAny -IPv4Address $ipv4

# Reiniciar el servicio DNS
Restart-Service DNS

Write-Host "[INFO] Configuración del servidor DNS completada con éxito."
