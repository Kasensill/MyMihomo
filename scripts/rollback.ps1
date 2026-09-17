# ==========================================
# MyMihomo Rollback
# ==========================================

Write-Host ""
Write-Host "=========================================="
Write-Host " MyMihomo Rollback"
Write-Host "=========================================="
Write-Host ""


try {

    # ==========================================
    # 确定路径
    # ==========================================

    $ConfigDir = Join-Path `
        $PSScriptRoot `
        "..\config"

    $BackupDir = Join-Path `
        $ConfigDir `
        "backup"

    $CurrentConfig = Join-Path `
        $ConfigDir `
        "config.yaml"

    $MihomoBinary = Join-Path `
        $PSScriptRoot `
        "..\bin\mihomo-windows-amd64-compatible.exe"


    # ==========================================
    # 检查必要文件和目录
    # ==========================================

    if (-not (Test-Path $BackupDir)) {

        throw "Backup directory not found: $BackupDir"
    }


    if (-not (Test-Path $MihomoBinary)) {

        throw "Mihomo binary not found: $MihomoBinary"
    }


    # ==========================================
    # 找到最近一次自动备份
    # ==========================================
    #
    # 备份文件命名格式：
    #
    # auto-yyyyMMdd-HHmmss.yaml
    #
    # 例如：
    #
    # auto-20260906-164540.yaml
    # auto-20260906-170612.yaml
    #
    # 因为时间格式是固定长度，
    # 文件名按字典序倒序排列
    # 就等价于按时间倒序排列。
    #
    # 这里不能使用 LastWriteTime，
    # 因为 Copy-Item 可能保留源文件的修改时间。
    #


    $LatestBackup = Get-ChildItem `
        -Path $BackupDir `
        -Filter "auto-*.yaml" `
        -File |
        Sort-Object Name -Descending |
        Select-Object -First 1


    if (-not $LatestBackup) {

        throw "No automatic backup found."
    }


    Write-Host "Latest backup:"
    Write-Host $LatestBackup.FullName
    Write-Host ""

    # Validate the selected backup before stopping the working process.
    $ValidationDir = Join-Path $ConfigDir "candidate-test\rollback"
    $ValidationConfig = Join-Path $ValidationDir "config.yaml"
    New-Item -ItemType Directory -Path $ValidationDir -Force -ErrorAction Stop | Out-Null
    Copy-Item -LiteralPath $LatestBackup.FullName -Destination $ValidationConfig -Force -ErrorAction Stop
    & $MihomoBinary -t -d $ValidationDir
    if ($LASTEXITCODE -ne 0) {
        throw "Selected backup failed validation; running Mihomo was not stopped."
    }


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
    # 恢复配置
    # ==========================================

    Copy-Item `
        $LatestBackup.FullName `
        $CurrentConfig `
        -Force `
        -ErrorAction Stop


    Write-Host "Config restored."
    Write-Host $CurrentConfig
    Write-Host ""


    # ==========================================
    # 验证恢复后的配置
    # ==========================================

    Write-Host "Testing restored config..."
    Write-Host ""


    & $MihomoBinary -t -d $ConfigDir


    if ($LASTEXITCODE -ne 0) {

        throw "Restored config test failed."
    }


    Write-Host ""
    Write-Host "Restored config test successful."
    Write-Host ""


    # ==========================================
    # 启动恢复后的 Mihomo
    # ==========================================

    Write-Host "Starting Mihomo..."


    $StartedProcess = Start-Process `
        -FilePath $MihomoBinary `
        -ArgumentList "-d `"$ConfigDir`"" `
        -PassThru `
        -ErrorAction Stop


    # ==========================================
    # 等待恢复后的 Mihomo 就绪
    # ==========================================

    Write-Host ""
    Write-Host "Waiting for restored Mihomo to become ready..."


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

        throw "Restored Mihomo failed to become ready within 15 seconds."
    }


    Write-Host ""
    Write-Host "Mihomo is running. PID = $($NewMihomo.Id)"
    Write-Host "Port 7890 is listening."
    Write-Host "Port 9090 is listening."
    Write-Host ""


    # ==========================================
    # 测试代理连接
    # ==========================================

    Write-Host "Testing proxy connectivity..."
    Write-Host ""


    & "$PSScriptRoot\test-proxy.ps1"


    if (-not $?) {

        throw "Proxy connectivity test failed after rollback."
    }


    # ==========================================
    # 回滚成功
    # ==========================================

    Write-Host ""
    Write-Host "=========================================="
    Write-Host " MyMihomo rollback successful"
    Write-Host "=========================================="
    Write-Host ""

    return
}


catch {

    Write-Host ""
    Write-Host "=========================================="
    Write-Host " MyMihomo rollback FAILED"
    Write-Host "=========================================="
    Write-Host ""

    Write-Host "Error:"
    Write-Host $_.Exception.Message
    Write-Host ""

    throw
}
