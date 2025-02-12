#************************************************************************************************
# Script para la automatizar la creación de un servidor DNS en PowerShell


# Solicitar al usuario el dominio y la IP
$dominio = Read-Host "Ingrese el nombre del dominio (por ejemplo: misitio.com)"
$ip = Read-Host "Ingrese la dirección IP del Dominio (Server: 192.168.0.199)"

# Función para validar la dirección IP con expresión regular
function ValidarIp {
    param([string]$ip)
    # Regex para validar una dirección IP
    $regex = '^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    return $ip -match $regex
}

# Validar la dirección IP del servidor DNS
if (-not (ValidarIp $ip)) {
    Write-Host "La dirección IP proporcionada no es válida. Por favor, ingrese una IP válida."
    Exit 1
}

# Instalar el rol de servidor DNS si no está instalado
Install-WindowsFeature -Name DNS

# Configurar el servidor DNS para resolver peticiones
# Crear una zona DNS para el dominio ingresado
Add-DnsServerPrimaryZone -Name $dominio -ZoneFile "$dominio.dns" -DynamicUpdate "NonSecureAndSecure"

# Crear el registro A para el dominio ingresado y asignar la IP proporcionada
Add-DnsServerResourceRecordA -ZoneName $dominio -Name "@" -AllowUpdateAny -IPv4Address $ip
Add-DnsServerResourceRecordA -Name "www" -ZoneName "$dominio" -AllowUpdateAny -IPv4Address "$ip"
# Crear la zona inversa para buscar por IP
$ipSeg = $ip.Split('.')
$ipInversa = "$($ipSeg[2]).$($ipSeg[1]).$($ipSeg[0]).in-addr.arpa"
Add-DnsServerPrimaryZone -Name $ipInversa -ZoneFile "$ipInversa.dns" -DynamicUpdate "NonSecureAndSecure"

# Crear el registro PTR para la zona inversa
Add-DnsServerResourceRecordPTR -ZoneName $ipInversa -Name "$($ipSeg[3])" -PTRDomainName "$dominio"


# Reinicio de servidor
Restart-Service DNS
    
# Configurar el servidor DNS para responder a consultas (forwarders)
Write-Host "El servidor fue configurado correctamente!!"