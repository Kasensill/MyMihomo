Write-Host ""
Write-Host "Testing proxy connectivity..."
Write-Host ""

$ProxyTestSuccess = $false

# 等待 Mihomo 启动并稳定
Start-Sleep -Seconds 20

for ($i = 1; $i -le 3; $i++) {

    Write-Host "Proxy test attempt $i/3..."

    curl.exe -4 --connect-timeout 15 `
        -x http://127.0.0.1:7890 `
        https://www.google.com -I

    if ($LASTEXITCODE -eq 0) {
        $ProxyTestSuccess = $true
        break
    }

    if ($i -lt 3) {
        Write-Host "Proxy test failed. Retrying in 2 seconds..."
        Start-Sleep -Seconds 2
    }
}

if ($ProxyTestSuccess) {

    Write-Host ""
    Write-Host "Proxy connectivity test successful."
    exit 0
}

Write-Host ""
Write-Host "ERROR: Proxy connectivity test failed after 3 attempts."
exit 1