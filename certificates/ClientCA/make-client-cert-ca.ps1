# Ustawienia
$domain = "localhost"
$san = "DNS=localhost, DNS=test-raspberrypi"
$subject = "CN=$domain, O=SpCraft"
$friendlyName = "SpCraft.FileUploader Client Certificate"
$password = ConvertTo-SecureString -String "tajnehaslo123" -AsPlainText -Force
$pfxPath = Join-Path -Path $PSScriptRoot -ChildPath "$friendlyName.pfx"
$caCertThumbprint = "e4fe30a3f11fbabc6ea4498652b545948b044f87"  # Wprowadź tutaj thumbprint certyfikatu CA

# Znalezienie certyfikatu CA
$caCert = Get-ChildItem -Path "cert:\LocalMachine\CA" | Where-Object { $_.Thumbprint -eq $caCertThumbprint }
if (-not $caCert) {
    Write-Host "Nie znaleziono certyfikatu CA o podanym thumbprincie."
    exit
}

# Extract the certificate object
$caCertObject = [System.Security.Cryptography.X509Certificates.X509Certificate2]$caCert

# Utworzenie certyfikatu klienta
$cert = New-SelfSignedCertificate `
    -CertStoreLocation "cert:\LocalMachine\My" `
    -KeyLength 2048 `
    -KeyExportPolicy Exportable `
    -NotAfter (Get-Date).AddYears(1) `
    -Signer $caCertObject `
    -Subject $subject `
    -FriendlyName $friendlyName `
    -KeyUsage DigitalSignature `
    -TextExtension @(
        "2.5.29.37={text}1.3.6.1.5.5.7.3.2",  # Client Authentication EKU
        "2.5.29.17={text}$san", 
        "2.5.29.19={text}CA=false"
    )

# Eksportowanie certyfikatu do pliku PFX
Export-PfxCertificate -Cert $cert -FilePath $pfxPath -Password $password

# Opcjonalnie: usunięcie certyfikatu z magazynu, jeśli chcesz go usunąć
# Remove-Item -Path "cert:\LocalMachine\My\$($cert.Thumbprint)"