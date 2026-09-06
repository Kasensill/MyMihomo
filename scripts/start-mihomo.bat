@echo off
setlocal

cd /d "%~dp0"

:: ==========================================
:: 检查管理员权限
:: ==========================================

net session >nul 2>&1

if %errorlevel% neq 0 (
echo Requesting administrator privileges...
powershell -Command "Start-Process '%~f0' -Verb RunAs"
exit /b
)

echo.
echo ==========================================
echo MyMihomo
echo ==========================================
echo.

:: ==========================================
:: 检查 Mihomo 是否已经运行
:: ==========================================

echo [1/4] Checking Mihomo process...

tasklist /FI "IMAGENAME eq mihomo-windows-amd64-compatible.exe" | find /I "mihomo-windows-amd64-compatible.exe" >nul

if %errorlevel% equ 0 (
echo Mihomo is already running.
echo.
goto CHECK_PORTS
)

echo Mihomo is not running.
echo.

:: ==========================================
:: 启动 Mihomo
:: ==========================================

echo [2/4] Starting Mihomo with TUN...
echo.

start "" "..\bin\mihomo-windows-amd64-compatible.exe" -d "..\config"

echo Mihomo start command executed.
echo.

:: 等待 Mihomo 初始化
echo Waiting for Mihomo to initialize...
timeout /t 5 /nobreak >nul

:: ==========================================
:: 检查端口
:: ==========================================

:CHECK_PORTS

echo [3/4] Checking Mihomo ports...

powershell -Command "$p = Get-NetTCPConnection -LocalPort 7890 -State Listen -ErrorAction SilentlyContinue; if ($p) { exit 0 } else { exit 1 }"

if %errorlevel% neq 0 (
echo.
echo ERROR: Port 7890 is not listening.
echo Mihomo may have failed to start.
echo.
pause
exit /b 1
)

powershell -Command "$p = Get-NetTCPConnection -LocalPort 9090 -State Listen -ErrorAction SilentlyContinue; if ($p) { exit 0 } else { exit 1 }"

if %errorlevel% neq 0 (
echo.
echo ERROR: Port 9090 is not listening.
echo Mihomo may have failed to start.
echo.
pause
exit /b 1
)

echo Port 7890 is listening.
echo Port 9090 is listening.
echo.

:: ==========================================
:: 测试代理连接
:: ==========================================

echo [4/4] Testing proxy connectivity...
echo.

powershell -ExecutionPolicy Bypass -File ".\test-proxy.ps1"

if %errorlevel% neq 0 (
echo.
echo ==========================================
echo MyMihomo startup FAILED
echo ==========================================
echo.
echo Proxy connectivity test failed.
echo.
pause
exit /b 1
)

echo.
echo ==========================================
echo MyMihomo started successfully
echo Global TUN proxy is active
echo ==========================================
echo.

pause
