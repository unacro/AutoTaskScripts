$Workspace = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $Workspace
$Version = "1.0.0"
$Updated = "2020-04-06"

#=================================================
#   Author: Cyanashi
#   Version: 1.0.0
#   Updated: 2020-04-06
#   Required: CentOS/Debian/Ubuntu
#   Description: 示例描述信息
#   Link: https://github.com/Cyanashi/AutoTaskScripts
#=================================================

Write-Host "当前脚本版本 v$($Version) 当前脚本路径为 $($Workspace)"
Write-Host "最后更新时间 $($Updated)"
