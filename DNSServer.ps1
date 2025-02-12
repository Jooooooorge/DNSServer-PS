# Solicitar al usuario el dominio y la IP
$domain = Read-Host "Ingrese el nombre del dominio (por ejemplo: misitio.com)"
$ipAddress = Read-Host "Ingrese la dirección IP del Dominio (Server: 192.168.0.199)"

# Función para validar la dirección IP con expresión regular
function Validate-IP {
    param([string]$IP)
    # Regex para validar una dirección IP
    $regex = '^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    return $IP -match $regex
}

# Validar la dirección IP del servidor DNS
if (-not (Validate-IP $ipAddress)) {
    Write-Host "La dirección IP proporcionada no es válida. Por favor, ingrese una IP válida."
    Exit 1
}

# Instalar el rol de servidor DNS si no está instalado
Install-WindowsFeature -Name DNS

# Configurar el servidor DNS para resolver peticiones
    # Crear una zona DNS para el dominio ingresado
    Add-DnsServerPrimaryZone -Name $domain -ZoneFile "$domain.dns" -DynamicUpdate "NonSecureAndSecure"

    # Crear el registro A para el dominio ingresado y asignar la IP proporcionada
    Add-DnsServerResourceRecordA -ZoneName $domain -Name "@" -AllowUpdateAny -IPv4Address $ipAddress
    
    # Crear la zona inversa para buscar por IP
    $ipParts = $ipAddress.Split('.')
    $reverseIp = "$($ipParts[2]).$($ipParts[1]).$($ipParts[0]).in-addr.arpa"
    Add-DnsServerPrimaryZone -Name $reverseIp -ZoneFile "$reverseIp.dns" -DynamicUpdate "NonSecureAndSecure"
    
    # Crear el registro PTR para la zona inversa
    Add-DnsServerResourceRecordPTR -ZoneName $reverseIp -Name "$($ipParts[3])" -PTRDomainName "$domain"
    
    # Configurar el servidor DNS para responder a consultas (forwarders)
    Set-DnsServerForwarder -IPAddress $ipAddres
    Write-Host "El servidor fue configurado correctamente!!"
