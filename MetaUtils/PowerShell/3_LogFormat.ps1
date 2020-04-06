function Write-Log {
    [CmdletBinding()]
    param (
        [String]$Content,
        [String]$Level = "INFO"
    )
    $current = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $Content = $Content.Replace("`n", "`n                      ")
    $log = "[$($current)] $($Level.ToUpper()) | $($Content)"
    if ($Level -eq "DEBUG") { Write-Host $log -ForegroundColor Black -BackgroundColor White }
    elseif ($Level -eq "NOTICE") { Write-Host $log -ForegroundColor Cyan }
    elseif ($Level -eq "INFO") { Write-Host $log -ForegroundColor White }
    elseif ($Level -eq "SUCCESS") { Write-Host $log -ForegroundColor Green }
    elseif ($Level -eq "WARN") { Write-Host $log -ForegroundColor Yellow }
    elseif ($Level -eq "ERROR") { Write-Host $log -ForegroundColor Red }
    elseif ($Level -eq "FATAL") { Write-Host $log -ForegroundColor White -BackgroundColor Red }
    elseif ($Level -eq "DIVIDER") { Write-Host "====================================================================================================" -ForegroundColor Gray }
}

Write-Log "这是一条 Debug 信息" debug
Write-Log "这是一条 Notice 信息" notice
Write-Log "这是一条 Info 信息" info
Write-Log "这是一条 Success 信息" success
Write-Log "这是一条 Warning 信息" warn
Write-Log "这是一条 Error 信息" error
Write-Log "这是一条 Fatal 信息" fatal
Write-Log "这是一条 分割线" divider
Write-Log "Log 类型并不区分大小写" DivIdeR
Write-Log -Level divider
