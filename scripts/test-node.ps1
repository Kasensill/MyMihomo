. "$PSScriptRoot\extract-node.ps1"

$Node = Get-HysteriaNode

Write-Host ""
Write-Host "========== Node =========="
Write-Host "Name   = $($Node.Name)"
Write-Host "Type   = $($Node.Type)"
Write-Host "Server = $($Node.Server)"
Write-Host "Port   = $($Node.Port)"
Write-Host "Auth   = $($Node.Auth)"
Write-Host "Sni    = $($Node.Sni)"
Write-Host "Verify = $($Node.SkipCertVerify)"
Write-Host "Alpn   = $($Node.Alpn)"
Write-Host "Proto  = $($Node.Protocol)"
Write-Host "Up     = $($Node.Up)"
Write-Host "Down   = $($Node.Down)"