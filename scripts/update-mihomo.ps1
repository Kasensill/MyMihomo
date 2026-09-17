# ==========================================
# MyMihomo Update
# ==========================================

Write-Host ""
Write-Host "=========================================="
Write-Host " MyMihomo Update"
Write-Host "=========================================="
Write-Host ""

$Promoted = $false
$BackupFile = $null
$WasRunning = $false
$StartedProcess = $null

try {

    # ==========================================
    # 确定路径
    # ==========================================

    $ConfigDir = Join-Path `
        $PSScriptRoot `
        "..\config"

    $CurrentConfig = Join-Path `
        $ConfigDir `
        "config.yaml"

    $CandidateConfig = Join-Path `
        $ConfigDir `
        "config-new.yaml"

    $BackupDir = Join-Path `
        $ConfigDir `
        "backup"

    $CandidateDir = Join-Path `
        $ConfigDir `
        "candidate-test"

    $CandidateTestConfig = Join-Path `
        $CandidateDir `
        "config.yaml"

    $MihomoBinary = Join-Path `
        $PSScriptRoot `
        "..\bin\mihomo-windows-amd64-compatible.exe"


    # ==========================================
    # 检查必要文件
    # ==========================================

    if (-not (Test-Path $MihomoBinary)) {

        throw "Mihomo binary not found: $MihomoBinary"
    }


    # ==========================================
    # 检查当前 Mihomo 状态
    # ==========================================

    $Mihomo = Get-Process `
        -Name "mihomo-windows-amd64-compatible" `
        -ErrorAction SilentlyContinue


    if ($Mihomo) {

        $WasRunning = $true
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

        throw "Official config download failed."
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

        throw "Candidate config generation failed. Current config.yaml was NOT changed."
    }


    if (-not (Test-Path $CandidateConfig)) {

        throw "Generated config-new.yaml was not found."
    }


    Write-Host ""
    Write-Host "[2/3] Candidate config generation successful."
    Write-Host ""


    # ==========================================
    # 第三步：验证候选配置
    # ==========================================

    Write-Host "[3/3] Testing candidate Mihomo config..."
    Write-Host ""


    if (-not (Test-Path $CandidateDir)) {

        New-Item `
            -ItemType Directory `
            -Path $CandidateDir `
            -ErrorAction Stop |
            Out-Null
    }


    Copy-Item `
        $CandidateConfig `
        $CandidateTestConfig `
        -Force `
        -ErrorAction Stop


    Write-Host "Candidate config copied to test directory."
    Write-Host ""


    & $MihomoBinary -t -d $CandidateDir


    if ($LASTEXITCODE -ne 0) {

        throw "Candidate config test failed. Current config.yaml was NOT changed."
    }


    Write-Host ""
    Write-Host "Candidate config test successful."
    Write-Host ""


    # ==========================================
    # 备份当前正式配置
    # ==========================================

    if (-not (Test-Path $BackupDir)) {

        New-Item `
            -ItemType Directory `
            -Path $BackupDir `
            -ErrorAction Stop |
            Out-Null
    }


    if (Test-Path $CurrentConfig) {

        $TimeStamp = Get-Date -Format "yyyyMMdd-HHmmss"

        $BackupFile = Join-Path `
            $BackupDir `
            "auto-$TimeStamp.yaml"


        Copy-Item `
            $CurrentConfig `
            $BackupFile `
            -ErrorAction Stop


        Write-Host "Current config backed up:"
        Write-Host $BackupFile
    }
    else {

        Write-Host "No current config to backup."
    }


    Write-Host ""


    # ==========================================
    # 候选配置升级为正式配置
    # ==========================================

    Copy-Item `
        $CandidateConfig `
        $CurrentConfig `
        -Force `
        -ErrorAction Stop


    $Promoted = $true
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


        Stop-Process `
            -Id $Mihomo.Id `
            -ErrorAction Stop


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


    $StartedProcess = Start-Process `
        -FilePath $MihomoBinary `
        -ArgumentList "-d `"$ConfigDir`"" `
        -PassThru `
        -ErrorAction Stop


    Write-Host "MyMihomo start command executed."
    Write-Host ""


    # ==========================================
    # 等待 Mihomo 就绪
    # ==========================================

    Write-Host "Waiting for Mihomo to become ready..."


    $Ready = $false


    for ($i = 1; $i -le 15; $i++) {

        Start-Sleep -Seconds 1


        $NewMihomo = Get-Process -Id $StartedProcess.Id -ErrorAction SilentlyContinue


        $Port7890 = Get-NetTCPConnection `
            -LocalPort 7890 `
            -State Listen `
            -ErrorAction SilentlyContinue


        $Port9090 = Get-NetTCPConnection `
            -LocalPort 9090 `
            -State Listen `
            -ErrorAction SilentlyContinue


        $Port7890Owned = @($Port7890 | Where-Object OwningProcess -eq $StartedProcess.Id)
        $Port9090Owned = @($Port9090 | Where-Object OwningProcess -eq $StartedProcess.Id)

        if ($NewMihomo -and $Port7890Owned -and $Port9090Owned) {

            $Ready = $true

            break
        }


        Write-Host "Waiting... $i/15"
    }


    if (-not $Ready) {

        throw "New Mihomo failed to become ready within 15 seconds."
    }


    Write-Host ""
    Write-Host "MyMihomo is ready."
    Write-Host "PID = $($NewMihomo.Id)"
    Write-Host "Port 7890 is listening."
    Write-Host "Port 9090 is listening."
    Write-Host ""


    # ==========================================
    # 故障演练开关
    # ==========================================

    # 正常使用必须保持 $false
    # 测试自动回滚时才改成 $true

    $ForceRollbackTest = $false


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


        # The outer catch block owns restoration so every post-promotion
        # failure follows the same exact-backup recovery path.
        throw "New Mihomo health check failed. Automatic restoration required."
    }


    # ==========================================
    # 故障演练
    # ==========================================

    if ($ForceRollbackTest) {

        Write-Host ""
        Write-Host "TEST: Forcing rollback after Mihomo startup."
        Write-Host ""

        Invoke-Rollback
    }


    # ==========================================
    # 测试代理连接
    # ==========================================

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

}
catch {

    $OriginalError = $_.Exception.Message

    if ($Promoted -and $BackupFile -and (Test-Path -LiteralPath $BackupFile)) {
        Write-Host "Update failed after promotion. Restoring the exact pre-update backup..."
        try {
            if ($StartedProcess) {
                Stop-Process -Id $StartedProcess.Id -Force -ErrorAction SilentlyContinue
            }
            Copy-Item -LiteralPath $BackupFile -Destination $CurrentConfig -Force -ErrorAction Stop
            & $MihomoBinary -t -d $ConfigDir
            if ($LASTEXITCODE -ne 0) { throw "Restored configuration failed validation." }
            if ($WasRunning) {
                Start-Process -FilePath $MihomoBinary -ArgumentList "-d `"$ConfigDir`"" -ErrorAction Stop | Out-Null
            }
            Write-Host "Pre-update configuration restored successfully."
        }
        catch {
            Write-Host "CRITICAL: Automatic restoration failed: $($_.Exception.Message)"
        }
    }

    Write-Host ""
    Write-Host "=========================================="
    Write-Host " MyMihomo update FAILED"
    Write-Host "=========================================="
    Write-Host ""

    Write-Host "Error:"
    Write-Host $OriginalError
    Write-Host ""

    throw
}
