# Ustawienia certyfikatu
$certName = "CN=SpCraft Root CA"
$certPassword = ConvertTo-SecureString -String "8BUGhFo^GC7GAK" -Force -AsPlainText
$pfxPath = Join-Path -Path $PSScriptRoot -ChildPath "DevCA.pfx"

# Tworzenie certyfikatu root CA
$cert = New-SelfSignedCertificate -DnsName $certName -CertStoreLocation "cert:\LocalMachine\My" `
    -KeyUsage CertSign, CRLSign, DigitalSignature `
    -KeyLength 2048 `
    -NotAfter (Get-Date).AddYears(10) `
    -HashAlgorithm SHA256 `
    -KeyExportPolicy Exportable `
    -TextExtension @("2.5.29.19={text}CA=true&pathlength=0")

# Eksportowanie certyfikatu do pliku .pfx
Export-PfxCertificate -Cert $cert -FilePath $pfxPath -Password $certPassword

# Dodanie certyfikatu do lokalnego magazynu certyfikatów (opcjonalne)
#$cert | Set-Location -Path "cert:\LocalMachine\Root"