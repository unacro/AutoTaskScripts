<##
 # Author: Cyanashi(imwhtl@gmail.com)
 # Version: 2.0.2
 # Last_Updated: 2020-04-02
 # Description: ArchiSteamFarm ASF自动部署脚本
 #>

$psVersion = ([String]$psversiontable.PSVersion).Substring(0, 3)
if ([Double]$psVersion -lt 5) {
    Write-Host "[Warn] PowerShell 版本过低（$($psVersion)），此脚本不支持 5.1 以下的版本。" -ForegroundColor Yellow
    exit
}

$Script:Version = "2.0.2"
$Script:Updated = "2020-04-02"
$Script:ASFVersion = ""
$got_zip = $false
$got_exe = $false
$desktop = [System.Environment]::GetFolderPath('Desktop')
$workspace = Split-Path -Parent $MyInvocation.MyCommand.Definition
$zipPath = $workspace + '\ASF-win-x64.zip'
$corePath = $workspace + '\core'
$7zPath = $env:ProgramFiles + '\7-Zip\7z.exe'
Set-Location $workspace
Add-Type -AssemblyName System.Windows.Forms
function Get-MsgBox {
    param (
        [String]$Prompt = "默认内容",
        [System.Windows.Forms.MessageBoxButtons]$Buttons = [System.Windows.Forms.MessageBoxButtons]::OK,
        [String]$Title = "默认标题",
        [System.Windows.Forms.MessageBoxIcon]$Icon = [System.Windows.Forms.MessageBoxIcon]::None
    )
    return [System.Windows.Forms.MessageBox]::Show($Prompt, $Title, $Buttons, $Icon)
}
function Copy-Files {
    [CmdletBinding()]
    param (
        [String]$origin_folder = "",
        [String]$new_folder = "",
        [Switch]$force
    )
    $files = Get-ChildItem $origin_folder -Recurse
    foreach ($item in $files) {
        if ($item.fullname -like "*appsettings.json*") { continue }
        $new_item = $item.fullname.Replace($origin_folder, $new_folder) # 取完整路径
        # 如果目标文件存在则先判断新旧
        if (Test-Path $new_item) {
            # 如果是目录则跳过 如果不跳过 则会创建一级空目录
            if (-not ((Get-ChildItem $new_item).PSIsContainer)) {
                # 如果目标位置存在 [修改时间早于源文件的] 文件 则重新拷贝并覆盖
                if ($force -or (Get-ChildItem $new_item).lastwritetime -lt $item.lastwritetime) { Copy-Item $item.fullname $new_item -Force }
            }
        }
        # 如果目标文件不存在直接拷贝
        Else { Copy-Item $item.fullname $new_item }
    }
}
function Get-DownloadUrl {
    $response = Invoke-WebRequest -URI "https://api.github.com/repos/JustArchiNET/ArchiSteamFarm/releases/latest" -UseBasicParsing | Select-Object -ExpandProperty Content | ConvertFrom-Json
    if ($null -eq $response) { return "" }
    else {
        $response.assets | ForEach-Object {
            if ($_.browser_download_url.Contains('win')) { return $_.browser_download_url }
        }
    }
}
function Test-ZipFile {
    if (Test-Path $zipPath) { return $true }
    else { return $false }
}
function Test-ASF {
    if (Test-Path $corePath) {
        Get-ChildItem $corePath | ForEach-Object -Process {
            if ($_ -is [System.IO.FileInfo] -and $_.name -eq "ArchiSteamFarm.exe") { return $true }
        }
        return $false
    }
    else { return $false }
}
function Get-ZipFile {
    if (Test-ZipFile) {
        $downloadConfirm = Get-MsgBox -Title "压缩包已存在" -Prompt "检测到当前目录下已存在 ASF-win-x64.zip 文件，是否重新下载？" -Buttons YesNo  -Icon Warning
        if ($downloadConfirm -eq 'No') { return $true }
    }
    $assetUrl = Get-DownloadUrl
    if ([String]::IsNullOrEmpty($assetUrl)) {
        Write-Host "[Error] 获取最新稳定版下载地址失败，请检查网络。或前往 https://github.com/JustArchiNET/ArchiSteamFarm/releases 手动下载正确版本（ASF-win-x64.zip）。" -ForegroundColor Red
        Read-Host "按下回车键继续" | Out-Null
        if (-not (Test-ZipFile)) { return $false }
    }
    $Script:ASFVersion = (($assetUrl -split "download/")[1] -split "/ASF-win-x64.zip")[0]
    Write-Host "[Info] 开始下载 ArchiSteamFarm Version 最新稳定版 $($Script:ASFVersion) 压缩包 [ASF-win-x64.zip]..."
    if (Test-Path 'ASF-win-x64.tmp') { Remove-Item 'ASF-win-x64.tmp' }
    Invoke-WebRequest -URI $assetUrl -OutFile 'ASF-win-x64.tmp'
    if (Test-Path $zipPath) { Remove-Item $zipPath }
    Rename-Item "$($workspace)\ASF-win-x64.tmp" $zipPath
    if (Test-ZipFile) {
        Write-Host "[Info] ArchiSteamFarm v$($Script:ASFVersion) 下载完成，位于 $($zipPath) 。" -ForegroundColor Green
        return $true
    }
    else {
        Write-Host "[Error] ArchiSteamFarm v$($Script:ASFVersion) 下载失败，请重试。或者访问 $($assetUrl) 手动下载。" -ForegroundColor Red
        return $false
    }
}
function Expand-ZipFile {
    Write-Host "[Info] 开始解压 ArchiSteamFarm Version 压缩包 $($Script:ASFVersion) [ASF-win-x64.zip]..."
    if (Test-Path $7zPath) {
        Set-Alias sz $7zPath
        sz x "$zipPath" -y -o"$corePath"
        Write-Host "[Info] [ASF-win-x64.zip] 解压成功，解压后文件位于 $corePath 。" -ForegroundColor Green
        return $true
    }
    else {
        Write-Host "[Warn] 未在默认目录 $7zPath 找到 7-Zip 程序。`n       请指定 7-Zip 主程序（\7-Zip\7z.exe）路径，或手动解压 $zipPath 。" -ForegroundColor Yellow
        return $false
    }
}
function Get-FileReady {
    if (Test-ASF) { return }
    else {
        do {
            # Read-Host "[Debug] WTF" | Out-Null
            if (Get-ZipFile) {
                $got_zip = $true
                do {
                    if (Expand-ZipFile) {
                        $got_exe = $true
                        if (Test-ASF) { return }
                        else {
                            Write-Host "[Fatal] 没有在 $($workspace)\core 找到 ArchiSteamFarm 主程序，如果一直出现这个错误，请备份好配置文件并删除 .\core 文件夹后重试。" -BackgroundColor Red
                            exit
                        }
                    }
                    else {
                        if (Test-ASF) { return }
                        else {
                            $7zPath = Read-Host "输入 7-Zip 主程序路径"
                            Write-Host $7zPath
                            if (-not $7zPath.ToLower().EndsWith('.exe')) { $7zPath = $7zPath.TrimEnd('\/') + "\7z.exe" }
                        }
                    }
                } while (-not $got_exe)
            }
        } while (-not $got_zip)
    }
}
function Import-Config {
    if (Test-Path "$($workspace)\config") {
        $importConfirm = Get-MsgBox -Title "准备导入配置文件" -Prompt "如果导入过程中发现冲突的文件，是否强制覆盖？`n若选择「否」，则会保留二者中较新的部分。" -Buttons YesNoCancel -Icon Question
        if ($importConfirm -eq 'Cancel') { Write-Host "[Info] 取消应用配置文件。" }
        else {
            # Write-Host "$($workspace)\config >> $($corePath)\config" -ForegroundColor Yellow
            if ($importConfirm -eq 'Yes') { Copy-Files "$($workspace)\config" "$($corePath)\config" -Force }
            elseif ($importConfirm -eq 'No') { Copy-Files "$($workspace)\config" "$($corePath)\config" }
            Write-Host "[Info] 已应用配置文件。" -ForegroundColor Green
        }
    }
}
function New-Shortcut {
    $shortcutPath
    $shortcutTip
    $shortcutConfirm = Get-MsgBox -Title "准备创建快捷方式" -Prompt "是否在桌面创建快捷方式？`n若选择「否」，则会在「脚本所在目录」建立快捷方式。" -Buttons YesNoCancel -Icon Question
    if ($shortcutConfirm -eq 'Yes') {
        $shortcuts = "$($desktop)\ASF.lnk", "$($corePath)\ArchiSteamFarm.exe", "$($desktop)\ASF Config.lnk", "$($corePath)\config", "桌面"
    }
    elseif ($shortcutConfirm -eq 'No') {
        $shortcuts = "$($workspace)\ASF.lnk", "$($corePath)\ArchiSteamFarm.exe", "$($workspace)\ASF Config.lnk", "$($corePath)\config", "此脚本同级目录下"
    }
    elseif ($shortcutConfirm -eq 'Cancel') {
        Write-Host "[Info] 取消创建相关快捷方式。"
        return
    }
    $shell = New-Object -ComObject WScript.Shell
    $i = 0
    while ($i -lt 4) {
        $lnk = $shell.CreateShortcut($shortcuts[$i++])
        $lnk.TargetPath = $shortcuts[$i++]
        $lnk.Save()
    }
    Write-Host "[Info] 相关快捷方式已建立，位于$($shortcuts[4])。" -ForegroundColor Green
}
function Exit-WithAnyKey {
    Write-Host "[Info] 所有任务已完成，按任意键关闭窗口。"
    [Console]::Readkey() | Out-Null
    exit
}
function Backup-Config {
    if (Test-ASF) {
        $backupConfirm = Get-MsgBox -Title "备份配置文件" -Prompt "是否备份当前配置文件？" -Buttons YesNo  -Icon Warning
        if ($backupConfirm -eq 'Yes') {
            if (-not (Test-Path "$($workspace)\backup")) { New-Item -ItemType Directory "$($workspace)\backup" }
            $current = Get-Date -Format 'yyyyMMdd_HHmmss'
            Compress-Archive -Path "$($corePath)\config" -DestinationPath "$($workspace)\backup\config_配置备份_$($current)" -Force
        }
    }
}

Write-Host "[Info] 脚本当前版本v$($Script:Version) $($Script:Updated)" -ForegroundColor Cyan
Backup-Config
Get-FileReady
Write-Host "[Info] ArchiSteamFarm 主程序准备完成。" -ForegroundColor Cyan
Import-Config
Start-Sleep -Milliseconds 500
New-Shortcut
Exit-WithAnyKey
