$url = Read-Host "Please enter the URL"

if (-not ($url -match "^http[s]?://")) {
    $url = "https://$url"
}

$uri = New-Object System.Uri($url)
$hostname = $uri.Host

try {
    $tcpClient = New-Object Net.Sockets.TcpClient
    $tcpClient.Connect($hostname, 443)

    $sslStream = New-Object Net.Security.SslStream($tcpClient.GetStream())
    $sslStream.AuthenticateAsClient($hostname)
    $certificate = $sslStream.RemoteCertificate
    $tcpClient.Close()

    if ($certificate) {
        $cert = New-Object Security.Cryptography.X509Certificates.X509Certificate2 $certificate

        Write-Host "Certificate information for $($url):"
        Write-Host "Subject: $($cert.Subject)"
        Write-Host "Issuer: $($cert.Issuer)"
        Write-Host "Thumbprint: $($cert.Thumbprint)"
        Write-Host "Valid From: $($cert.NotBefore)"
        Write-Host "Valid To: $($cert.NotAfter)"
    } else {
        Write-Host "No certificate information available for $url."
    }
} catch {
    Write-Host "An error occurred while retrieving the certificate for $url."
    Write-Host "Error: $_"
}
