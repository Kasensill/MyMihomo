function Get-MyMihomoSettings {

    param (
        [string]$SettingsFile = ""
    )

    if ([string]::IsNullOrWhiteSpace($SettingsFile)) {

        $SettingsFile = Join-Path $PSScriptRoot "..\config\settings.yaml"
    }

    $Lines = Get-Content $SettingsFile -Encoding UTF8

    $Settings = [PSCustomObject]@{
        OfficialConfigPath = ""
        OfficialConfigUrl  = ""
    }

    for ($i = 0; $i -lt $Lines.Count; $i++) {

        $Line = $Lines[$i]

        if ($Line -match '^\s+path:\s*"(.+)"$') {

            $Settings.OfficialConfigPath = $Matches[1]
        }

        if ($Line -match '^\s+url:\s*"(.+)"$') {

            $Settings.OfficialConfigUrl = $Matches[1]
        }
    }

    return $Settings
}


function Get-HysteriaNode {

    param (
        [string]$ConfigFile = ""
    )

    if ([string]::IsNullOrWhiteSpace($ConfigFile)) {

        $Settings = Get-MyMihomoSettings

        $ConfigFile = $Settings.OfficialConfigPath
    }

    if ([string]::IsNullOrWhiteSpace($ConfigFile)) {

        Write-Host "ERROR: Official config path is not configured."
        exit 1
    }

    $Lines = Get-Content $ConfigFile -Encoding UTF8

    $Node = [PSCustomObject]@{
        Name            = ""
        Type            = ""
        Server          = ""
        Port            = ""
        Auth            = ""
        Sni             = ""
        SkipCertVerify  = ""
        Alpn            = ""
        Protocol        = ""
        Up              = ""
        Down            = ""
    }

    $InProxies = $false

    for ($i = 0; $i -lt $Lines.Count; $i++) {

        $Line = $Lines[$i]

        if ($Line -eq "proxies:") {

            $InProxies = $true
            continue
        }

        if ($Line -eq "proxy-groups:") {

            break
        }

        if (-not $InProxies) {

            continue
        }

        if ($Line -match '^\s+- name:\s*(.+)$') {

            $Node.Name = $Matches[1]
        }

        if ($Line -match '^\s+type:\s*(.+)$') {

            $Node.Type = $Matches[1]
        }

        if ($Line -match '^\s+server:\s*(.+)$') {

            $Node.Server = $Matches[1]
        }

        if ($Line -match '^\s+port:\s*(.+)$') {

            $Node.Port = $Matches[1]
        }

        if ($Line -match '^\s+auth-str:\s*(.+)$') {

            $Node.Auth = $Matches[1]
        }

        if ($Line -match '^\s+sni:\s*(.+)$') {

            $Node.Sni = $Matches[1]
        }

        if ($Line -match '^\s+skip-cert-verify:\s*(.+)$') {

            $Node.SkipCertVerify = $Matches[1]
        }

        if ($Line -match '^\s+alpn:\s*$') {

            $NextLine = $Lines[$i + 1]

            if ($NextLine -match '^\s+-\s*(.+)$') {

                $Node.Alpn = $Matches[1]
            }
        }

        if ($Line -match '^\s+protocol:\s*(.+)$') {

            $Node.Protocol = $Matches[1]
        }

        if ($Line -match '^\s+up:\s*(.+)$') {

            $Node.Up = $Matches[1]
        }

        if ($Line -match '^\s+down:\s*(.+)$') {

            $Node.Down = $Matches[1]
        }
    }

    return $Node
}