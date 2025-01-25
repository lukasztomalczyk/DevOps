# Ustawienia
$domain = "localhost"
$san = "DNS=localhost, DNS=test-raspberrypi"
$subject = "CN=$domain, O=SpCraft"
$friendlyName = "SpCraft.FileUploader client certificate"
$password = ConvertTo-SecureString -String "tajnehaslo123" -AsPlainText -Force
$pfxPath = Join-Path -Path $PSScriptRoot -ChildPath "$domain.pfx"
$caCertThumbprint = "c7481aadf7f4a79ea9dd0f8c8bf010b567570686"  # Wprowadź tutaj thumbprint certyfikatu CA

# Znalezienie certyfikatu CA
$caCert = Get-ChildItem -Path "cert:\LocalMachine\Ca" | Where-Object { $_.Thumbprint -eq $caCertThumbprint }
if (-not $caCert) {
    Write-Host "Nie znaleziono certyfikatu CA o podanym thumbprincie."
    exit
} else {
    Write-Host "Znaleziono certyfikat CA:"
    Write-Host "Thumbprint: $($caCert.Thumbprint)"
    Write-Host "Subject: $($caCert.Subject)"
}

# Extract the certificate object
$caCertObject = [System.Security.Cryptography.X509Certificates.X509Certificate2]$caCert

# Debugging output to verify the CA certificate object
Write-Host "CA Certificate Object Type: $($caCertObject.GetType().FullName)"
Write-Host "CA Certificate Thumbprint: $($caCertObject.Thumbprint)"
Write-Host "CA Certificate Subject: $($caCertObject.Subject)"

# Utworzenie certyfikatu klienta
$cert = New-SelfSignedCertificate -CertStoreLocation "cert:\LocalMachine\My" -KeyLength 2048 -KeyExportPolicy Exportable -NotAfter (Get-Date).AddYears(1) -Signer $caCertObject -Subject $subject -FriendlyName $friendlyName -KeyUsage DigitalSignature -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2", "2.5.29.17={text}$san")

# Eksportowanie certyfikatu do pliku PFX
Export-PfxCertificate -Cert $cert -FilePath $pfxPath -Password $password

# Opcjonalnie: usunięcie certyfikatu z magazynu, jeśli chcesz go usunąć
# Remove-Item -Path "cert:\LocalMachine\My\$($cert.Thumbprint)"