# Solicitar al usuario el dominio y la IP
$domain = Read-Host "Ingrese el nombre del dominio"
$ipAddress = Read-Host "Ingrese la dirección IP del servidor DNS"

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
    Add-DnsServerPrimaryZone -Name $domain -ZoneFile "$domain.dns"

    # Configurar el servidor DNS para responder a consultas
    Set-DnsServerForwarder -IPAddress $ipAddress

    Write-Host "El servidor DNS ha sido configurado para el dominio $domain con la IP $ipAddress."
} else {
    Write-Host "No se encontró una interfaz de red activa. Asegúrate de que la interfaz de red esté habilitada."
}
