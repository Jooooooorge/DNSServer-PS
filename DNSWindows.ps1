# Solicitar al usuario el dominio y la IP
$domain = Read-Host "Ingrese el nombre del dominio (por ejemplo: misitio.com)"
$ipAddress = Read-Host "Ingrese la dirección IP del servidor DNS (por ejemplo: 192.168.1.10)"

# Función para validar la dirección IP con expresión regular
function Validate-IP {
    param([string]$IP)
    # Regex para validar una dirección IP IPv4
    $regex = '^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    return $IP -match $regex
}

# Validar la dirección IP del servidor DNS
if (-not (Validate-IP $ipAddress)) {
    Write-Host "[ERROR] La dirección IP proporcionada no es válida. Por favor, ingrese una IP válida."
    Exit 1
}

# Instalar el rol de servidor DNS si no está instalado
$dnsRole = Get-WindowsFeature -Name DNS
if ($dnsRole.Installed -eq $false) {
    Install-WindowsFeature -Name DNS
    Write-Host "El rol de servidor DNS ha sido instalado."
} else {
    Write-Host "El rol de servidor DNS ya está instalado."
}

# Configurar el servidor DNS
$dnsServer = Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true }

if ($dnsServer) {
    Write-Host "Configurando servidor DNS..."
    
    # Establecer la IP de la interfaz de red
    $dnsServer.SetDNSServerSearchOrder($ipAddress)
    
    # Crear una zona DNS para el dominio ingresado
    try {
        Add-DnsServerPrimaryZone -Name $domain -ZoneFile "$domain.dns" -DynamicUpdate "NonSecureAndSecure"
        Write-Host "Zona primaria creada para el dominio $domain."
    } catch {
        Write-Host "[ERROR] No se pudo crear la zona primaria. Verifica los permisos o si ya existe una zona con el mismo nombre."
        Exit 1
    }

    # Crear el registro A para el dominio ingresado y asignar la IP proporcionada
    try {
        Add-DnsServerResourceRecordA -ZoneName $domain -Name "@" -AllowUpdateAny -IPv4Address $ipAddress
        Write-Host "Registro A creado para el dominio $domain con la IP $ipAddress."
    } catch {
        Write-Host "[ERROR] No se pudo crear el registro A para el dominio $domain."
        Exit 1
    }

    # Configurar el servidor DNS para responder a consultas (forwarders)
    Set-DnsServerForwarder -IPAddress $ipAddress
    Write-Host "El servidor DNS ha sido configurado para el dominio $domain con la IP $ipAddress."
} else {
    Write-Host "[ERROR] No se encontró una interfaz de red activa. Asegúrate de que la interfaz de red esté habilitada."
    Exit 1
}
