# Ustawienia
$domain = "localhost"
$san = "DNS=localhost, DNS=test-raspberrypi"
$subject = "CN=$domain, O=SpCraft"
$friendlyName = "SpCraft.FileUploader Server Certificate"
$password = ConvertTo-SecureString -String "tajnehaslo123" -AsPlainText -Force
$pfxPath = Join-Path -Path $PSScriptRoot -ChildPath "$domain.pfx"
$caCertThumbprint = "7b3586b538f534ec412c5238383bd3efbf205967"  # Wprowadź tutaj thumbprint certyfikatu Intermediate CA

# Znalezienie certyfikatu Intermediate CA
$caCert = Get-ChildItem -Path "cert:\LocalMachine\CA" | Where-Object { $_.Thumbprint -eq $caCertThumbprint }
if (-not $caCert) {
    Write-Host "Nie znaleziono certyfikatu Intermediate CA o podanym thumbprincie."
    exit
} else {
    Write-Host "Znaleziono certyfikat Intermediate CA:"
    Write-Host "Thumbprint: $($caCert.Thumbprint)"
    Write-Host "Subject: $($caCert.Subject)"
}

# Extract the certificate object
$caCertObject = [System.Security.Cryptography.X509Certificates.X509Certificate2]$caCert

# Debugging output to verify the Intermediate CA certificate object
Write-Host "Intermediate CA Certificate Object Type: $($caCertObject.GetType().FullName)"
Write-Host "Intermediate CA Certificate Thumbprint: $($caCertObject.Thumbprint)"
Write-Host "Intermediate CA Certificate Subject: $($caCertObject.Subject)"

# Utworzenie certyfikatu serwera
$cert = New-SelfSignedCertificate -CertStoreLocation "cert:\LocalMachine\My" -KeyLength 2048 -KeyExportPolicy Exportable -NotAfter (Get-Date).AddYears(1) -Signer $caCertObject -Subject $subject -FriendlyName $friendlyName -KeyUsage DigitalSignature, KeyEncipherment -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.1", "2.5.29.17={text}$san", "2.5.29.19={text}CA=false")

# Eksportowanie certyfikatu do pliku PFX
Export-PfxCertificate -Cert $cert -FilePath $pfxPath -Password $password

# Opcjonalnie: usunięcie certyfikatu z magazynu, jeśli chcesz go usunąć
# Remove-Item -Path "cert:\LocalMachine\My\$($cert.Thumbprint)"