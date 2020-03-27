<##
 # Author: Cyanashi(imwhtl@gmail.com)
 # Version: 1.0.3
 # Last_Updated: 2020-03-27
 # Description: Win2Linux cwRsync 同步脚本
 #     Windows 利用 cwRsync 通过 SSH 同步文件到 Linux
 #
 #     cwRsync 客户端我是在 https://www.rsync.net/resources/howto/windows_rsync.html 下的绿色版
 #     可以直接点击 https://www.rsync.net/resources/binaries/cwRsync_5.4.1_x86_Free.zip 下载
 #>

################################ CONFIG BEGIN ################################
$Config = @{
    cwRsyncPath       = "D:\Workspace\Tools\cwRsync_5.4.1_x86_Free" # 如果这里没有填写cwRsync整体目录需要在下面分别填写单独的路径
    rsyncPath         = "" # e.g. D:\Workspace\Tools\cwRsync_5.4.1_x86_Free\rsync.exe
    sshPath           = "" # e.g. D:\Workspace\Tools\cwRsync_5.4.1_x86_Free\ssh.exe
    sshPrivateKeyPath = "D:\Workspace\Tools\NetSarang Computer\6\Xshell\Sessions\ssh-key\id_rsa" # 私钥文件
    localDir          = "D:\Document\Blog\hexo\public\" # 注意这里如果末尾不带斜杠就是直接同步 [整个文件夹] 到远程目录下
    remoteDir         = "/www/wwwroot/yoursite"
    remoteUser        = "root"
    remoteHost        = "192.168.199.199"
    remotePort        = "22"
    args              = "--progress -avzr --delete --no-g --chmod=ug=rwx,o=rX --exclude=.git --exclude=.github --exclude=.well-known" # 这里是rsync的参数
}
################################  CONFIG END  ################################

$script:cwRsync = @{ rsync = ""; ssh = ""; args = ""; }
$script:Sync = @{ pri_key = ""; local = ""; remote = ""; user = ""; host = ""; port = ""; }
$debug = $false
function ConvertTo-POSIX {
    [CmdletBinding()]
    param (
        [String]$path = ""
    )
    return "/cygdrive/" + $path.Replace("\", "/").Replace(":/", "/")
}
function Test-Config {
    [CmdletBinding()]
    param (
        [Hashtable]$config = $null
    )
    if ($null -eq $config) {
        Write-Host "[ERROR] Not Get Available Config Hashtable!"
        return $false
    }
    if (-not [String]::IsNullOrEmpty($config.cwRsyncPath) -and (Test-Path $config.cwRsyncPath)) {
        $script:cwRsync.rsync = $config.cwRsyncPath.TrimEnd("\/") + "\rsync.exe"
        $script:cwRsync.ssh = $config.cwRsyncPath.TrimEnd("\/") + "\ssh.exe"
    }
    else {
        $errorInfo = "[ERROR] Not Find Available cwRsync Client in:`n        $($config.cwRsyncPath)"
        if ([String]::IsNullOrEmpty($config.rsyncPath) -or -not (Test-Path $config.rsyncPath)) {
            $errorInfo += "`n        or`n        $($config.rsyncPath)"
            Write-Host $errorInfo
            return $false
        }
        if ([String]::IsNullOrEmpty($config.sshPath) -or -not (Test-Path $config.sshPath)) {
            $errorInfo += "`n        or`n        $($config.sshPath)"
            Write-Host $errorInfo
            return $false
        }
        else {
            Write-Host "[WARN] Not Set cwRsync`'s Path, Will Use Independent rsync & ssh Client."
            $script:cwRsync.rsync = $config.rsyncPath
            $script:cwRsync.ssh = $config.sshPath
        }
    }
    $script:cwRsync.args = $config.args
    if (-not [String]::IsNullOrEmpty($config.sshPrivateKeyPath) -and (Test-Path $config.sshPrivateKeyPath)) {
        $script:Sync.pri_key = ConvertTo-POSIX($config.sshPrivateKeyPath) # 不转格式会警告
    }
    elseif (-not [String]::IsNullOrEmpty($config.sshPrivateKeyPath) -and $config.sshPrivateKeyPath.Replace("\", "/").Startswith('/cygdrive/')) {
        $script:Sync.local = $config.sshPrivateKeyPath
    }
    else {
        Write-Host "[ERROR] Not Find Available SSH Private Key File @[$($config.sshPrivateKeyPath)]!"
        return $false
    }
    if (-not [String]::IsNullOrEmpty($config.localDir) -and (Test-Path $config.localDir)) {
        $script:Sync.local = ConvertTo-POSIX($config.localDir) # 不转格式直接报错
    }
    elseif (-not [String]::IsNullOrEmpty($config.localDir) -and $config.localDir.Replace("\", "/").Startswith('/cygdrive/')) {
        $script:Sync.local = $config.localDir
    }
    else {
        Write-Host "[ERROR] [$($config.localDir)] is NOT Available File or Directory!"
        return $false
    }
    if ([String]::IsNullOrEmpty($config.remoteHost)) {
        Write-Host "[ERROR] Please Set Right Host!"
        return $false
    }
    else {
        $ping = New-Object System.Net.Networkinformation.Ping
        $pingStatus = $ping.Send($config.remoteHost, 5000)
        if ($pingStatus.Status -eq "Success") {
            $script:Sync.host = $config.remoteHost
        }
        else {
            Write-Host "[ERROR] [$($config.remoteHost)] is NOT Available Host!"
            return $false
        }
    }
    if ([String]::IsNullOrEmpty($config.remoteDir)) {
        Write-Host "[WARN] Not Set Remote Directory, Use Default Directory [/tmp]."
        $script:Sync.remote = "/tmp/"
    }
    else {
        $script:Sync.remote = $config.remoteDir.TrimEnd("\/") + "/"
    }
    if ([String]::IsNullOrEmpty($config.remoteUser)) {
        Write-Host "[WARN] Not Set User, Use Default User [root]."
        $script:Sync.user = "root"
    }
    else {
        $script:Sync.user = $config.remoteUser
    }
    if ([String]::IsNullOrEmpty($config.remotePort)) {
        Write-Host "[WARN] Not Set User, Use Default Port [22]."
        $script:Sync.port = "22"
    }
    else {
        $script:Sync.port = $config.remotePort
    }
    return $true
}
function Invoke-Command {
    [CmdletBinding()]
    param (
        [Boolean]$is_debug = $true
    )
    $commandString = "$($script:cwRsync.rsync) $($script:cwRsync.args) "
    $commandString += "-e `"$($script:cwRsync.ssh) -p $($script:Sync.port) -i `'$($script:Sync.pri_key)`'`" "
    $commandString += "$($script:Sync.local) $($script:Sync.user)@$($script:Sync.host):$($script:Sync.remote)"
    if ($is_debug) {
        $debugInfo = "[DEBUG] Try to exec this command:`n" + $commandString
        Write-Host $debugInfo
    }
    else {
        $command = [scriptblock]::Create($commandString)
        & $command
    }
}
function Exit-WithAnyKey {
    Write-Host "Press any key to exit."
    [Console]::Readkey() | Out-Null
    Exit
}

if (Test-Config($Config)) {
    Write-Output $script:cwRsync
    Write-Output $script:Sync
}
else {
    Write-Host "Process End!"
    Exit-WithAnyKey
    Exit
}
#$debug = $true
Invoke-Command($debug)
