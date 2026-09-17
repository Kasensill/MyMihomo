param (
    [int]$Attempts = 3,
    [int]$InitialDelaySeconds = 3
)

if ($InitialDelaySeconds -gt 0) { Start-Sleep -Seconds $InitialDelaySeconds }

$Targets = @(
    # HTTP endpoints avoid depending on the Windows account's TLS certificate
    # store; Mihomo still transports the foreign request through the proxy.
    @{ Name = 'foreign'; Url = 'http://www.gstatic.com/generate_204' },
    @{ Name = 'domestic'; Url = 'http://www.baidu.com/' }
)

foreach ($Target in $Targets) {
    $Success = $false
    for ($Attempt = 1; $Attempt -le $Attempts; $Attempt++) {
        Write-Host "Testing $($Target.Name) connectivity ($Attempt/$Attempts)..."
        curl.exe -4 --fail --silent --show-error --output NUL --connect-timeout 10 --max-time 20 `
            -x http://127.0.0.1:7890 $Target.Url
        if ($LASTEXITCODE -eq 0) { $Success = $true; break }
        if ($Attempt -lt $Attempts) { Start-Sleep -Seconds 2 }
    }
    if (-not $Success) {
        Write-Error "$($Target.Name) connectivity test failed."
        exit 1
    }
}

Write-Host "Proxy and direct connectivity tests succeeded."
exit 0
