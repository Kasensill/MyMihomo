param (
    [string]$ConfigFile = ""
)


# ==========================================
# 加载依赖脚本
# ==========================================

. "$PSScriptRoot\extract-node.ps1"
. "$PSScriptRoot\get-route-exclude.ps1"


# ==========================================
# 确定官方配置文件
# ==========================================

if ([string]::IsNullOrWhiteSpace($ConfigFile)) {

    $ConfigFile = Join-Path $PSScriptRoot "..\config\official-latest.yaml"
}


# ==========================================
# 提取节点
# ==========================================

$Node = Get-HysteriaNode $ConfigFile


if ([string]::IsNullOrWhiteSpace($Node.Server)) {

    Write-Host ""
    Write-Host "ERROR: Hysteria node was not found in official config."
    exit 1
}


# ==========================================
# 计算路由排除地址
# ==========================================

$RouteExclude = Get-RouteExcludeAddress $Node.Server


# ==========================================
# 确定模板和输出文件
# ==========================================

$TemplateFile = Join-Path $PSScriptRoot "..\config\template.yaml"

$OutputFile = Join-Path $PSScriptRoot "..\config\config-new.yaml"


# ==========================================
# 读取模板
# ==========================================

$Content = Get-Content $TemplateFile -Raw -Encoding UTF8


# ==========================================
# 替换节点信息
# ==========================================

$Content = $Content.Replace("AUTO_NAME", $Node.Name)
$Content = $Content.Replace("AUTO_TYPE", $Node.Type)
$Content = $Content.Replace("AUTO_SERVER", $Node.Server)
$Content = $Content.Replace("AUTO_ROUTE_EXCLUDE", $RouteExclude)
$Content = $Content.Replace("AUTO_PORT", $Node.Port)
$Content = $Content.Replace("AUTO_AUTH", $Node.Auth)
$Content = $Content.Replace("AUTO_SNI", $Node.Sni)
$Content = $Content.Replace("AUTO_VERIFY", $Node.SkipCertVerify)
$Content = $Content.Replace("AUTO_ALPN", $Node.Alpn)
$Content = $Content.Replace("AUTO_PROTOCOL", $Node.Protocol)
$Content = $Content.Replace("AUTO_UP", $Node.Up.Trim('"'))
$Content = $Content.Replace("AUTO_DOWN", $Node.Down.Trim('"'))
$Content = $Content.Replace("AUTO_NODE", $Node.Name)


# ==========================================
# 写入候选配置
# ==========================================

$Content | Set-Content $OutputFile -Encoding UTF8


# ==========================================
# 输出结果
# ==========================================

Write-Host ""
Write-Host "=========================================="
Write-Host " Config generated"
Write-Host "=========================================="
Write-Host ""

Write-Host "Output:"
Write-Host $OutputFile