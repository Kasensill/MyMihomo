. "$PSScriptRoot\extract-node.ps1"


$Settings = Get-MyMihomoSettings


if ([string]::IsNullOrWhiteSpace($Settings.OfficialConfigUrl)) {

    Write-Host "ERROR: Official config URL is not configured."
    exit 1
}


$Url = $Settings.OfficialConfigUrl

$OutputFile = Join-Path $PSScriptRoot "..\config\official-latest.yaml"


Write-Host ""
Write-Host "=========================================="
Write-Host " Download Official Config"
Write-Host "=========================================="
Write-Host ""

Write-Host "URL:"
Write-Host $Url
Write-Host ""

Write-Host "Output:"
Write-Host $OutputFile
Write-Host ""


try {

    Invoke-WebRequest `
        -Uri $Url `
        -OutFile $OutputFile `
        -UseBasicParsing


    if (Test-Path $OutputFile) {

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

    Write-Host "Download failed."
    Write-Host ""

    Write-Host $_.Exception.Message

    exit 1
}