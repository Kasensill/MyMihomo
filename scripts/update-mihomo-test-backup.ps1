# ==========================================
# MyMihomo Update
# ==========================================

Write-Host ""
Write-Host "=========================================="
Write-Host " MyMihomo Update"
Write-Host "=========================================="
Write-Host ""


# ==========================================
# 检查当前 Mihomo 状态
# ==========================================

$Mihomo = Get-Process `
    -Name "mihomo-windows-amd64-compatible" `
    -ErrorAction SilentlyContinue

if ($Mihomo) {

    Write-Host "Mihomo is currently running. PID = $($Mihomo.Id)"
}
else {

    Write-Host "Mihomo is not running."
}

Write-Host ""


# ==========================================
# 第一步：下载官方最新配置
# ==========================================

Write-Host "[1/3] Downloading official config..."
Write-Host ""

& "$PSScriptRoot\download-official.ps1"

if (-not $?) {

    Write-Host ""
    Write-Host "ERROR: Official config download failed."
    exit 1
}

Write-Host ""
Write-Host "[1/3] Download successful."
Write-Host ""


# ==========================================
# 第二步：生成自己的 Mihomo 配置
# ==========================================

Write-Host "[2/3] Generating MyMihomo config..."
Write-Host ""

& "$PSScriptRoot\generate-config.ps1"

if (-not $?) {

    Write-Host ""
    Write-Host "ERROR: Candidate config generation failed."
    Write-Host "Current config.yaml was NOT changed."
    exit 1
}

Write-Host ""
Write-Host "[2/3] Candidate config generation successful."
Write-Host ""


# ==========================================
# 第三步：验证候选配置
# ==========================================

Write-Host "[3/3] Testing candidate Mihomo config..."
Write-Host ""

$ConfigDir = Join-Path $PSScriptRoot "..\config"

$CandidateDir = Join-Path $ConfigDir "candidate-test"

$CandidateConfig = Join-Path $CandidateDir "config.yaml"


if (-not (Test-Path $CandidateDir)) {

    New-Item `
        -ItemType Directory `
        -Path $CandidateDir |
        Out-Null
}


Copy-Item `
    (Join-Path $ConfigDir "config-new.yaml") `
    $CandidateConfig `
    -Force


Write-Host "Candidate config copied to test directory."
Write-Host ""


$MihomoBinary = Join-Path `
    $PSScriptRoot `
    "..\bin\mihomo-windows-amd64-compatible.exe"


& $MihomoBinary -t -d $CandidateDir


if ($LASTEXITCODE -ne 0) {

    Write-Host ""
    Write-Host "ERROR: Candidate config test failed."
    Write-Host "Current config.yaml was NOT changed."
    exit 1
}


Write-Host ""
Write-Host "Candidate config test successful."
Write-Host ""


# ==========================================
# 备份当前正式配置
# ==========================================

$CurrentConfig = Join-Path `
    $ConfigDir `
    "config.yaml"

$BackupDir = Join-Path `
    $ConfigDir `
    "backup"


if (Test-Path $CurrentConfig) {

    if (-not (Test-Path $BackupDir)) {

        New-Item `
            -ItemType Directory `
            -Path $BackupDir |
            Out-Null
    }


    $TimeStamp = Get-Date -Format "yyyyMMdd-HHmmss"

    $BackupFile = Join-Path `
        $BackupDir `
        "auto-$TimeStamp.yaml"


    Copy-Item `
        $CurrentConfig `
        $BackupFile


    Write-Host "Current config backed up:"
    Write-Host $BackupFile
}
else {

    Write-Host "No current config to backup."
}


# ==========================================
# 候选配置升级为正式配置
# ==========================================

Copy-Item `
    (Join-Path $ConfigDir "config-new.yaml") `
    $CurrentConfig `
    -Force


Write-Host ""
Write-Host "Candidate config promoted to active config."
Write-Host ""


# ==========================================
# 停止当前 Mihomo
# ==========================================

$Mihomo = Get-Process `
    -Name "mihomo-windows-amd64-compatible" `
    -ErrorAction SilentlyContinue


if ($Mihomo) {

    Write-Host "Stopping current Mihomo. PID = $($Mihomo.Id)"

    Stop-Process -Id $Mihomo.Id

    Write-Host "Current Mihomo stopped."
}
else {

    Write-Host "Mihomo is not running."
}


Write-Host ""


# ==========================================
# 启动新的 Mihomo
# ==========================================

Write-Host "=========================================="
Write-Host " Starting MyMihomo"
Write-Host "=========================================="
Write-Host ""


Start-Process `
    -FilePath $MihomoBinary `
    -ArgumentList "-d `"$ConfigDir`""


Write-Host "MyMihomo start command executed."


Start-Sleep -Seconds 3


# ==========================================
# 自动回滚函数
# ==========================================

function Invoke-Rollback {

    Write-Host ""
    Write-Host "=========================================="
    Write-Host " New Mihomo health check failed"
    Write-Host " Starting automatic rollback..."
    Write-Host "=========================================="
    Write-Host ""

    try {

        & "$PSScriptRoot\rollback.ps1"

    }
    catch {

        Write-Host ""
        Write-Host "ERROR: Automatic rollback failed."
        Write-Host ""
        Write-Host $_.Exception.Message
        Write-Host ""

        exit 1
    }

    Write-Host ""
    Write-Host "Automatic rollback completed successfully."
    Write-Host ""

    exit 1
}


# ==========================================
# 检查新 Mihomo 是否运行
# ==========================================

$NewMihomo = Get-Process `
    -Name "mihomo-windows-amd64-compatible" `
    -ErrorAction SilentlyContinue


if (-not $NewMihomo) {

    Write-Host ""
    Write-Host "ERROR: MyMihomo failed to start."

    Invoke-Rollback
}


Write-Host "MyMihomo is running. PID = $($NewMihomo.Id)"


# ==========================================
# 检查端口
# ==========================================

$Port7890 = Get-NetTCPConnection `
    -LocalPort 7890 `
    -State Listen `
    -ErrorAction SilentlyContinue


$Port9090 = Get-NetTCPConnection `
    -LocalPort 9090 `
    -State Listen `
    -ErrorAction SilentlyContinue


if (-not $Port7890) {

    Write-Host ""
    Write-Host "ERROR: Port 7890 is not listening."

    Invoke-Rollback
}


if (-not $Port9090) {

    Write-Host ""
    Write-Host "ERROR: Port 9090 is not listening."

    Invoke-Rollback
}


Write-Host "Port 7890 is listening."
Write-Host "Port 9090 is listening."


# ==========================================
# 测试代理连接
# ==========================================

Write-Host ""
Write-Host "Testing proxy connectivity..."
Write-Host ""


& "$PSScriptRoot\test-proxy.ps1"


if (-not $?) {

    Invoke-Rollback
}


# ==========================================
# 更新成功
# ==========================================

Write-Host ""
Write-Host "=========================================="
Write-Host " MyMihomo update successful"
Write-Host "=========================================="
Write-Host ""