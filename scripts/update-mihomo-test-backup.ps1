# Backward-compatible entry point. The main updater now always performs
# candidate validation, backup, health checks, and automatic restoration.
& "$PSScriptRoot\update-mihomo.ps1"
exit $LASTEXITCODE
