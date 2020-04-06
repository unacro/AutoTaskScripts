$OSVersion = (wmic os get caption)[2]
$OSBits = if ([Environment]::Is64BitOperatingSystem) { '64' } else { '32' }
Write-Host "当前操作系统为 $($OSVersion)- $($OSBits)bit"
