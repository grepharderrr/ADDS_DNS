# Installer le rôle AD DS
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools -Verbose

# Configuration du nouveau domaine
$domainName = "example.com" # Remplacez par le nom de domaine souhaité
$domainAdmin = "Admin" # Remplacez par le nom de l'administrateur de domaine souhaité
$domainPassword = ConvertTo-SecureString "MotDePasse123!" -AsPlainText -Force # Remplacez par le mot de passe de l'administrateur de domaine souhaité

$domainConfigParams = @{
    DomainName = $domainName
    DomainAdministratorCredential = (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $domainAdmin, $domainPassword)
    InstallDNS = $true
    NoRebootOnCompletion = $true
}

Install-ADDSForest @domainConfigParams -Verbose

# Installer le rôle DNS
Install-WindowsFeature -Name DNS -IncludeManagementTools -Verbose

# Configurer le serveur DNS
$dnsZoneName = $domainName
$dnsZoneFile = "$dnsZoneName.dns" # Remplacez par le nom de fichier souhaité
$dnsZonePath = "C:\Windows\System32\dns\" + $dnsZoneFile

Add-DnsServerPrimaryZone -Name $dnsZoneName -ZoneFile $dnsZonePath -PassThru -Verbose

# Ajouter une entrée DNS pour le contrôleur de domaine
$dnsRecordName = "DC"
$dnsRecordIPAddress = "192.168.1.10" # Remplacez par l'adresse IP du contrôleur de domaine
$dnsRecordType = "A"

Add-DnsServerResourceRecord -ZoneName $dnsZoneName -Name $dnsRecordName -IPv4Address $dnsRecordIPAddress -Type $dnsRecordType -PassThru -Verbose
