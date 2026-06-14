$msixPath = 'E:\user_files\Downloads\aria2\HyPlayer.Package_2.1.39.5_x64.msix'
$sig = Get-AuthenticodeSignature $msixPath
$cert = $sig.SignerCertificate
if ($cert) {
    Write-Host '=== Signer Certificate ==='
    Write-Host "Subject: $($cert.Subject)"
    Write-Host "Issuer: $($cert.Issuer)"
    Write-Host "Thumbprint: $($cert.Thumbprint)"
    Write-Host "NotBefore: $($cert.NotBefore)"
    Write-Host "NotAfter: $($cert.NotAfter)"
    Write-Host ''
    $chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain
    $chain.Build($cert)
    Write-Host '=== Chain Status ==='
    foreach ($status in $chain.ChainStatus) {
        Write-Host "$($status.Status): $($status.StatusInformation)"
    }
    Write-Host "Chain valid: $($chain.Build($cert))"
} else {
    Write-Host 'No Authenticode signature found'
}

# Also check if SignPath cert is in trusted stores
Write-Host ''
Write-Host '=== Trusted People Store ==='
Get-ChildItem Cert:\CurrentUser\TrustedPeople | Where-Object { $_.Subject -like '*SignPath*' } | Format-List Subject, Thumbprint

Write-Host '=== Trusted Publishers Store ==='
Get-ChildItem Cert:\CurrentUser\TrustedPublisher | Where-Object { $_.Subject -like '*SignPath*' } | Format-List Subject, Thumbprint

Write-Host '=== Local Machine Trusted People ==='
Get-ChildItem Cert:\LocalMachine\TrustedPeople -ErrorAction SilentlyContinue | Where-Object { $_.Subject -like '*SignPath*' } | Format-List Subject, Thumbprint
