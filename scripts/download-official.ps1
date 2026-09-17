. "$PSScriptRoot\extract-node.ps1"


$Settings = Get-MyMihomoSettings


if ([string]::IsNullOrWhiteSpace($Settings.OfficialConfigUrl)) {

    Write-Host "ERROR: Official config URL is not configured."
    exit 1
}


$Url = $Settings.OfficialConfigUrl

$OutputFile = Join-Path $PSScriptRoot "..\config\official-latest.yaml"
$TemporaryFile = "$OutputFile.tmp"


Write-Host ""
Write-Host "=========================================="
Write-Host " Download Official Config"
Write-Host "=========================================="
Write-Host ""

Write-Host "URL:"
Write-Host "<configured in private settings.yaml>"
Write-Host ""

Write-Host "Output:"
Write-Host $OutputFile
Write-Host ""


try {

    Invoke-WebRequest `
        -Uri $Url `
        -OutFile $TemporaryFile `
        -UseBasicParsing


    if ((Test-Path $TemporaryFile) -and (Get-Item $TemporaryFile).Length -gt 0) {

        Copy-Item -LiteralPath $TemporaryFile -Destination $OutputFile -Force -ErrorAction Stop
        Remove-Item -LiteralPath $TemporaryFile -Force

        Write-Host "Download successful."
        Write-Host ""

        Write-Host "Output:"
        Write-Host $OutputFile

    }

    else {

        Write-Host "Download failed: file not found."
        exit 1
    }

}

catch {

    Remove-Item -LiteralPath $TemporaryFile -Force -ErrorAction SilentlyContinue

    Write-Host "Download failed."
    Write-Host ""

    Write-Host $_.Exception.Message

    exit 1
}
