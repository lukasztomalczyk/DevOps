# Ustawienia certyfikatu
$certName = "CN=SpCraft Intermediate Dev CA"
$certPassword = ConvertTo-SecureString -String "E%4N7L4*cRkwR3" -Force -AsPlainText
$pfxPath = Join-Path -Path $PSScriptRoot -ChildPath "SpCraft_Intermediate_Dev_CA.pfx"
$rootCaCertThumbprint = "c2c0aa4ddcae9e784079b65deaf5ff9ca20c5e68"  # Wprowadź tutaj thumbprint certyfikatu Root CA

# Znalezienie certyfikatu Root CA
$rootCaCert = Get-ChildItem -Path "cert:\LocalMachine\My" | Where-Object { $_.Thumbprint -eq $rootCaCertThumbprint }
if (-not $rootCaCert) {
    Write-Host "Nie znaleziono certyfikatu Root CA o podanym thumbprincie."
    exit
} else {
    Write-Host "Znaleziono certyfikat Root CA:"
    Write-Host "Thumbprint: $($rootCaCert.Thumbprint)"
    Write-Host "Subject: $($rootCaCert.Subject)"
}

# Extract the certificate object
$rootCaCertObject = [System.Security.Cryptography.X509Certificates.X509Certificate2]$rootCaCert

# Debugging output to verify the Root CA certificate object
Write-Host "Root CA Certificate Object Type: $($rootCaCertObject.GetType().FullName)"
Write-Host "Root CA Certificate Thumbprint: $($rootCaCertObject.Thumbprint)"
Write-Host "Root CA Certificate Subject: $($rootCaCertObject.Subject)"

# Tworzenie certyfikatu Intermediate CA
$cert = New-SelfSignedCertificate -DnsName $certName -CertStoreLocation "cert:\LocalMachine\My" `
    -KeyUsage CertSign, CRLSign, DigitalSignature `
    -KeyLength 2048 `
    -NotAfter (Get-Date).AddYears(10) `
    -HashAlgorithm SHA256 `
    -KeyExportPolicy Exportable `
    -TextExtension @("2.5.29.19={text}CA=true&pathlength=1") `
    -Signer $rootCaCertObject

# Eksportowanie certyfikatu do pliku .pfx
Export-PfxCertificate -Cert $cert -FilePath $pfxPath -Password $certPassword

# Dodanie certyfikatu do lokalnego magazynu certyfikatów (opcjonalne)
#$cert | Set-Location -Path "cert:\LocalMachine\Root"