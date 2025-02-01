param (
    [string]$certThumbprint
)

# Find the certificate in the LocalMachine\My store
$cert = Get-ChildItem -Path "cert:\LocalMachine\My" | Where-Object { $_.Thumbprint -eq $certThumbprint }
if (-not $cert) {
    Write-Host "Certificate with thumbprint $certThumbprint not found."
    exit
}

# Create an X509Chain object
$chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain

# Configure the chain to ignore revocation checking
$chain.ChainPolicy.RevocationMode = [System.Security.Cryptography.X509Certificates.X509RevocationMode]::NoCheck

# Build the chain for the certificate
$chain.Build($cert)

# Display the chain status
if ($chain.ChainStatus.Length -eq 0) {
    Write-Host "Certificate is valid."
} else {
    Write-Host "Certificate is invalid. Chain status:"
    foreach ($status in $chain.ChainStatus) {
        Write-Host " - $($status.Status): $($status.StatusInformation)"
    }
}