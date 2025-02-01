$cn = "SpCraft DEV CA"
$certPassword = ConvertTo-SecureString -String "E%4N7L4*cRkwR3" -Force -AsPlainText
$pfxPath = Join-Path -Path $PSScriptRoot -ChildPath "SpCraft_DEV_CA.pfx"
$rootCaCertThumbprint = "743cc02e0b176543f1f74332a0d98429a4f10947"  # Wprowadź tutaj thumbprint certyfikatu Root CA

# Znalezienie certyfikatu Root CA
$rootCaCert = Get-ChildItem -Path "cert:\LocalMachine\My" | Where-Object { $_.Thumbprint -eq $rootCaCertThumbprint }
if (-not $rootCaCert) {
    Write-Host "Nie znaleziono certyfikatu Root CA o podanym thumbprincie."
    exit
}

# Extract the certificate object
$rootCaCertObject = [System.Security.Cryptography.X509Certificates.X509Certificate2]$rootCaCert

# Tworzenie certyfikatu Intermediate CA
$cert = New-SelfSignedCertificate -CertStoreLocation "cert:\LocalMachine\My" `
    -KeyUsage CertSign, CRLSign, DigitalSignature `
    -KeyLength 2048 `
    -NotAfter (Get-Date).AddYears(10) `
    -HashAlgorithm SHA256 `
    -KeyExportPolicy Exportable `
    -Subject "CN=$cn" `
    -FriendlyName $cn `
    -TextExtension @("2.5.29.19={text}CA=true&pathlength=0") `
    -Signer $rootCaCertObject

# Eksportowanie certyfikatu do pliku .pfx
Export-PfxCertificate -Cert $cert -FilePath $pfxPath -Password $certPassword

# Dodanie certyfikatu do magazynu Intermediate Certification Authorities
# $cert | Export-Certificate -FilePath "C:\temp\intermediateCA.cer"
# Import-Certificate -FilePath "C:\temp\intermediateCA.cer" -CertStoreLocation "cert:\LocalMachine\CA"