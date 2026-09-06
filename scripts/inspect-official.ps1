$ConfigFile = "E:\software\VPN\Chrome135_AllNew_2026.7.15\clash.meta\config.yaml"

$Lines = Get-Content $ConfigFile -Encoding UTF8

for ($i = 0; $i -lt $Lines.Count; $i++) {

    $Line = $Lines[$i]

    if ($Line -match '^\s+server:\s*(.+)$') {
        Write-Host "SERVER = $($Matches[1])"
    }

    if ($Line -match '^\s+port:\s*(.+)$') {
        Write-Host "PORT   = $($Matches[1])"
    }

    if ($Line -match '^\s+auth-str:\s*(.+)$') {
        Write-Host "AUTH   = $($Matches[1])"
    }

    if ($Line -match '^\s+sni:\s*(.+)$') {
        Write-Host "SNI    = $($Matches[1])"
    }

    if ($Line -match '^\s+skip-cert-verify:\s*(.+)$') {
        Write-Host "VERIFY = $($Matches[1])"
    }

    if ($Line -match '^\s+protocol:\s*(.+)$') {
        Write-Host "PROTO  = $($Matches[1])"
    }

    if ($Line -match '^\s+alpn:\s*$') {

        $NextLine = $Lines[$i + 1]

        if ($NextLine -match '^\s+-\s*(.+)$') {
            Write-Host "ALPN   = $($Matches[1])"
        }
    }

    if ($Line -match '^\s+up:\s*(.+)$') {
        Write-Host "UP     = $($Matches[1])"
    }

    if ($Line -match '^\s+down:\s*(.+)$') {
        Write-Host "DOWN   = $($Matches[1])"
    }
}