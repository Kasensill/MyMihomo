Set-StrictMode -Version Latest

function Get-MyMihomoSettings {
    param ([string]$SettingsFile = "")
    if ([string]::IsNullOrWhiteSpace($SettingsFile)) {
        $SettingsFile = Join-Path $PSScriptRoot "..\config\settings.yaml"
    }
    if (-not (Test-Path -LiteralPath $SettingsFile)) {
        throw "Settings file not found: $SettingsFile"
    }

    $Settings = [PSCustomObject]@{ OfficialConfigPath = ""; OfficialConfigUrl = "" }
    foreach ($Line in Get-Content -LiteralPath $SettingsFile -Encoding UTF8) {
        if ($Line -match '^\s+path:\s*["'']?(.+?)["'']?\s*$') {
            $Settings.OfficialConfigPath = $Matches[1]
        }
        elseif ($Line -match '^\s+url:\s*["'']?(.+?)["'']?\s*$') {
            $Settings.OfficialConfigUrl = $Matches[1]
        }
    }
    return $Settings
}

function ConvertFrom-SimpleProxyBlock {
    param ([string[]]$Lines)

    $Node = [ordered]@{
        Name = ""; Type = ""; Server = ""; Port = ""; Auth = ""; Sni = ""
        SkipCertVerify = ""; Alpn = ""; Protocol = ""; Up = ""; Down = ""
    }
    $AlpnValues = [System.Collections.Generic.List[string]]::new()
    $ReadingAlpn = $false

    foreach ($Line in $Lines) {
        if ($Line -match '^\s+-?\s*(name|type|server|port|auth-str|sni|skip-cert-verify|protocol|up|down):\s*(.*?)\s*$') {
            $ReadingAlpn = $false
            $Value = $Matches[2].Trim().Trim('"').Trim("'")
            switch ($Matches[1]) {
                'name' { $Node.Name = $Value }; 'type' { $Node.Type = $Value }
                'server' { $Node.Server = $Value }; 'port' { $Node.Port = $Value }
                'auth-str' { $Node.Auth = $Value }; 'sni' { $Node.Sni = $Value }
                'skip-cert-verify' { $Node.SkipCertVerify = $Value }
                'protocol' { $Node.Protocol = $Value }; 'up' { $Node.Up = $Value }
                'down' { $Node.Down = $Value }
            }
        }
        elseif ($Line -match '^\s+alpn:\s*$') { $ReadingAlpn = $true }
        elseif ($ReadingAlpn -and $Line -match '^\s+-\s*["'']?(.+?)["'']?\s*$') {
            $AlpnValues.Add($Matches[1])
        }
    }
    if ($AlpnValues.Count -gt 0) { $Node.Alpn = $AlpnValues[0] }
    return [PSCustomObject]$Node
}

function Get-HysteriaNodes {
    param ([string]$ConfigFile = "")
    if ([string]::IsNullOrWhiteSpace($ConfigFile)) {
        $ConfigFile = (Get-MyMihomoSettings).OfficialConfigPath
    }
    if ([string]::IsNullOrWhiteSpace($ConfigFile)) { throw "Official config path is not configured." }
    if (-not (Test-Path -LiteralPath $ConfigFile)) { throw "Official config file not found: $ConfigFile" }

    $Lines = @(Get-Content -LiteralPath $ConfigFile -Encoding UTF8)
    $InProxies = $false
    $Block = [System.Collections.Generic.List[string]]::new()
    $Nodes = [System.Collections.Generic.List[object]]::new()

    foreach ($Line in $Lines) {
        if ($Line -match '^proxies:\s*$') { $InProxies = $true; continue }
        if ($InProxies -and $Line -match '^\S') { break }
        if (-not $InProxies) { continue }
        if ($Line -match '^\s{2}-\s+name:\s*' -and $Block.Count -gt 0) {
            $Parsed = ConvertFrom-SimpleProxyBlock -Lines $Block.ToArray()
            if ($Parsed.Type -in @('hysteria', 'hysteria2')) { $Nodes.Add($Parsed) }
            $Block.Clear()
        }
        if (-not [string]::IsNullOrWhiteSpace($Line)) { $Block.Add($Line) }
    }
    if ($Block.Count -gt 0) {
        $Parsed = ConvertFrom-SimpleProxyBlock -Lines $Block.ToArray()
        if ($Parsed.Type -in @('hysteria', 'hysteria2')) { $Nodes.Add($Parsed) }
    }
    return $Nodes.ToArray()
}

function Get-HysteriaNode {
    param ([string]$ConfigFile = "", [string]$NodeName = "")
    $Nodes = @(Get-HysteriaNodes -ConfigFile $ConfigFile)
    if ($Nodes.Count -eq 0) { throw "No supported Hysteria node was found in: $ConfigFile" }

    if (-not [string]::IsNullOrWhiteSpace($NodeName)) {
        $Selected = @($Nodes | Where-Object Name -eq $NodeName)
        if ($Selected.Count -ne 1) { throw "Expected one node named '$NodeName', found $($Selected.Count)." }
        $Node = $Selected[0]
    }
    else {
        if ($Nodes.Count -gt 1) { Write-Warning "Multiple Hysteria nodes found; using the first one. Pass -NodeName to select explicitly." }
        $Node = $Nodes[0]
    }

    foreach ($Required in @('Name', 'Type', 'Server', 'Port', 'Auth')) {
        if ([string]::IsNullOrWhiteSpace($Node.$Required)) { throw "Selected node is missing required field: $Required" }
    }
    return $Node
}
