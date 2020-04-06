$Workspace = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $Workspace
$Version = "1.1.0"
$Updated = "2020-04-06"
$Source = "https://github.com/Cyanashi/AutoTaskScripts/tree/master/Common/GetStreamLink"

#=================================================
#   Author: Cyanashi
#   Version: 1.1.0
#   Updated: 2020-04-06
#   Required: ^PowerShell 5.1
#   Description: Live Stream-link Source Parsing Tool 直播源获取工具
#   Link: https://ews.ink/develop/Get-Stream-Link
#=================================================

$Script:Args # 不必赋值[ = $args] $Script:Args 已经是参数了
$Script:Config
$Script:Input
$Script:LiveInfo = @{ }
$Script:Stream = @{ }

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

function Read-Config {
    Write-Log "正在读取配置文件"
    $config_path = $Workspace + "\config.json"
    if (Test-Path $config_path) {
        $config_string = Get-Content $config_path -Encoding UTF8
        # Win资源管理器菜单栏的路径默认为反斜杠\ 如果直接复制粘贴其实不是合法的JSON格式 此处进行输入容错
        Trap { Write-Log "配置文件不是正确的 JSON 格式" ERROR; return $false }
        & { $Script:Config = $config_string.Replace('\\', '/').Replace('\', '/') | ConvertFrom-Json }
        return $true
    }
    else {
        Write-Log "配置文件不存在 尝试初始化" WARN
        $default_room = @{ url = ""; site = "douyu"; room_id = ""; }
        $config = @{
            player       = "D:/Program/PotPlayer/PotPlayerMini64.exe";
            default      = $default_room;
            after_get    = 0;
        }
        $config | ConvertTo-Json | Out-File 'config.json' # 第一次启动生成默认配置文件
        $Script:Config = $config # 应用第一次生成的配置文件
        Write-Log "已生成默认的配置文件"
        return $true
    }
}

function Save-Config {
    $Script:Config | ConvertTo-Json | Out-File 'config.json'
}

function Get-LiveInfo {
    param (
        [Parameter(ValueFromPipeline = $true)]
        [String]$LiveUrl
    )
    $pattern = "(?<Site>bilibili|cc\.163|douyu|huya)\b\..*\/\b(?:.*\=)?(?<Room>\w+).*?(?<Exclude>m3u8)?$"
    if ($LiveUrl -match $pattern -and [String]::IsNullOrEmpty($matches.Exclude)) {
        return @{ Site = $matches.Site.Replace(".163", ""); Room = $matches.Room }
    }
    return $null
}

function Test-Input {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [String]$LiveUrl
    )
    $live_info = Get-LiveInfo $LiveUrl
    if ($null -eq $live_info) { return $false }
    return $true
}

function Initialize-Input {
    if ([String]::IsNullOrEmpty($Script:Args)) {
        $clipboard = Get-Clipboard
        if ($clipboard | Test-Input) {
            $Script:LiveInfo = $clipboard | Get-LiveInfo
            Write-Log "从剪切板读取到直播间 $($clipboard)" SUCCESS
            return $true
        }
        if (![String]::IsNullOrEmpty($Script:Config.default.url)) {
            if (Test-Input $Script:Config.default.url) {
                Write-Log "已设置默认直播间 $($Script:Config.default.url)" SUCCESS
                $Script:LiveInfo = $Script:Config.default.url | Get-LiveInfo
                return $true
            }
            Write-Log "已设置默认直播间 但不支持该url 请确认是此脚本支持的直播间地址" WARN
        }
        if (![String]::IsNullOrEmpty($Script:Config.default.room_id)) {
            $Script:LiveInfo.Room = $Script:Config.default.room_id
            Write-Log "已设置默认直播间房间号 $($Script:LiveInfo.Room)" SUCCESS
            if ($Script:Config.default.site -notmatch "\b(bilibili|cc|douyu|huya)\b") {
                $Script:LiveInfo.Site = "douyu"
                Write-Log "未检测到合法的直播平台设置 已默认视为斗鱼直播房间号" WARN
            }
            else {
                $Script:LiveInfo.Site = $Script:Config.default.site
                Write-Log "已设置默认直播平台 $($Script:Config.default.site)" SUCCESS
            }
            return $true
        }
        return $false
    }
    else {
        if ([String]::IsNullOrEmpty($Script:Args[1])) {
            # 就一个参数
            if (Test-Input $Script:Args[0]) {
                # 是直播间完整地址
                $Script:LiveInfo = $Script:Args[0] | Get-LiveInfo
                Write-Log "已应用直播间地址 $($Script:Args[0])" SUCCESS
                return $true
            }
            elseif ($Script:Args[0] -match '^(\w+)$') {
                # 仅直播间房间号
                $Script:LiveInfo.Room = $Script:Args[0]
                Write-Log "已应用直播间房间号 $($Script:Args[0])" SUCCESS
                if ($Script:Config.default.site -notmatch "\b(bilibili|cc|douyu|huya)\b") {
                    $Script:LiveInfo.Site = "douyu"
                    Write-Log "未检测到合法的直播平台设置 已默认视为斗鱼直播房间号" WARN
                }
                else {
                    $Script:LiveInfo.Site = $Script:Config.default.site
                    Write-Log "已设置默认直播平台 $($Script:Config.default.site)" SUCCESS
                }
                return $true
            }
            return $false
        }
        else {
            # 有两个参数
            if (Test-Path $Script:Args[0]) {
                # 第一个参数是播放器 第二个参数是直播间
                # TODO 是否要开临时变量存命令行传的播放器
                $Script:Config.player = $Script:Args[0] # 不开临时变量 直接用全局变量存的话 每次执行完命令行后可能会覆盖当前的配置文件
                Write-Log "已应用播放器路径 $($Script:Args[0])" SUCCESS
                if (Test-Input $Script:Args[1]) {
                    # 第二个参数是直播间完整地址
                    $Script:LiveInfo = $Script:Args[1] | Get-LiveInfo
                    Write-Log "已应用直播间地址 $($Script:Args[1])" SUCCESS
                    return $true
                }
                elseif ($Script:Args[1] -match '^(\w+)$') {
                    # 第二个参数仅直播间房间号
                    $Script:LiveInfo.Room = $Script:Args[1]
                    Write-Log "已应用直播间房间号 $($Script:Args[1])" SUCCESS
                    if ($Script:Config.default.site -notmatch "\b(bilibili|cc|douyu|huya)\b") {
                        $Script:LiveInfo.Site = "douyu"
                        Write-Log "未检测到合法的直播平台设置 已默认视为斗鱼直播房间号" WARN
                    }
                    else {
                        $Script:LiveInfo.Site = $Script:Config.default.site
                        Write-Log "已设置默认直播平台 $($Script:Config.default.site)" SUCCESS
                    }
                    return $true
                }
                else {
                    Write-Log "无法应用直播间地址 $($Script:Args[1])" WARN
                    return $false
                }
            }
            else {
                # 第一个参数是直播间 第二个参数是播放器
                if (Test-Input $Script:Args[0]) {
                    # 第一个参数是直播间完整地址
                    $Script:LiveInfo = $Script:Args[0] | Get-LiveInfo
                    Write-Log "已应用直播间地址 $($Script:Args[0])" SUCCESS
                }
                elseif ($Script:Args[0] -match '^(\w+)$') {
                    # 第一个参数仅直播间房间号
                    $Script:LiveInfo.Room = $Script:Args[0]
                    Write-Log "已应用直播间房间号 $($Script:Args[0])" SUCCESS
                    if ($Script:Config.default.site -notmatch "\b(bilibili|cc|douyu|huya)\b") {
                        $Script:LiveInfo.Site = "douyu"
                        Write-Log "未检测到合法的直播平台设置 已默认视为斗鱼直播房间号" WARN
                    }
                    else {
                        $Script:LiveInfo.Site = $Script:Config.default.site
                        Write-Log "已设置默认直播平台 $($Script:Config.default.site)" SUCCESS
                    }
                }
                else {
                    # 打印参数并指出错误部分
                    if ([String]::IsNullOrEmpty($Script:Args[0])) { $input_args = [String]$Script:Args[0] }
                    else {
                        $input_args = [String]$Script:Args[0]
                        For ($i = 1; $i -lt $Script:Args.Count; $i++) { $input_args += " $($Script:Args[$i])" }
                    }
                    Write-Log "输入参数非法 > $($input_args)`n[$($Script:Args[0])] 既不是直播间也不是播放器" WARN
                    return $false
                }
                if (Test-Path $Script:Args[1]) {
                    # 第二个参数可用的是播放器
                    $Script:Config.player = $Script:Args[1]
                    Write-Log "已应用播放器路径 $($Script:Args[1])" SUCCESS
                    return $true
                }
                else {
                    # 第二个参数不是可用的播放器
                    Write-Log "输入的播放器路径非法 $($Script:Args[1])" WARN
                    if (Test-Path $Script:Config.player) {
                        # 但配置文件设置了可用的播放器
                        Write-Log "已使用配置文件设置的播放器路径 $($Script:Config.player)"
                        return $true
                    }
                    else {
                        # ERROR 没有可用的播放器
                        return $false
                    }
                }
            }
        }
    }
}

function Get-StreamLink {
    if ($null -eq $Script:LiveInfo.Room) {
        return "没有设置直播间房间号"
    }
    $URI = @{
        Bilibili = "https://api.live.bilibili.com/xlive/web-room/v1/index/getRoomPlayInfo?room_id=$($Script:LiveInfo.Room)&play_url=1&mask=1&qn=0&platform=web";
        Douyu    = "https://web.sinsyth.com/lxapi/douyujx.x?roomid=$($Script:LiveInfo.Room)";
        Huya     = "https://m.huya.com/$($Script:LiveInfo.Room)";
        CC       = "https://vapi.cc.163.com/video_play_url/$($Script:LiveInfo.Room)?vbrname=blueray";
    }
    $script:Stream.Streamer = $Script:LiveInfo.Room
    if ($Script:LiveInfo.Site.ToLower() -eq "bilibili") {
        $response = Invoke-WebRequest -URI $URI.Bilibili -UseBasicParsing | Select-Object -ExpandProperty Content | ConvertFrom-Json
        if ($response.message -ne 0) {
            return $response.message
        }
        elseif ($response.data.live_status -eq 0) {
            return "B站直播间$($Script:LiveInfo.Room)没有开播"
        }
        Write-Log "数据抓取成功 开始解析直播源..."
        $user_info_api = "http://api.bilibili.com/x/space/acc/info?mid=$($response.data.uid)&jsonp=jsonp"
        $streamer_info = Invoke-WebRequest -URI $user_info_api -UseBasicParsing | Select-Object -ExpandProperty Content | ConvertFrom-Json
        $script:Stream.Streamer = $streamer_info.data.name
        $temp_link = "https://cn-hbxy-cmcc-live-01.live-play.acgvideo.com/live-bvc/live_" + ($response.data.play_url.durl[0].url -split "/live_")[1]
        $Script:Stream.Link = ($temp_link -split ".flv?")[0].Replace("_1500", "_1500") + ".m3u8" # 经测试某些直播源删掉清晰度画面会损坏
        return $null
    }
    elseif ($Script:LiveInfo.Site.ToLower() -eq "cc") {
        $timestamp_hex = "{0:x}" -f [Int](([DateTime]::Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).tostring().Substring(0, 10)
        $sid = Invoke-WebRequest -URI "https://vapi.cc.163.com/sid?src=webcc" -UseBasicParsing
        $URI.CC += "&t=$($timestamp_hex)&sid=$($sid)&urs=null&src=webcc_4000&vbrmode=1&secure=1"
        try {
            $response = Invoke-WebRequest -URI $URI.CC -UseBasicParsing | Select-Object -ExpandProperty Content | ConvertFrom-Json
        }
        catch {
            $result = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($result)
            $reader.BaseStream.Position = 0
            $reader.DiscardBufferedData()
            $response = $reader.ReadToEnd() | ConvertFrom-Json
        }
        if ($null -ne $response.code) {
            if ($response.code -eq "Gone") {
                return "网易CC直播间$($Script:LiveInfo.Room)没有开播"
            }
            else {
                return "网易CC直播间$($Script:LiveInfo.Room)已经开播"
            }
        }
        # 数据抓取成功 开始解析直播源...
        Write-Log "数据抓取成功 开始解析直播源..."
        $script:Stream.Streamer = $Script:LiveInfo.Room #TODO 获取主播名字
        $Script:Stream.Link = $response.videourl
        return $null
    }
    elseif ($Script:LiveInfo.Site.ToLower() -eq "douyu") {
        $response = Invoke-WebRequest -URI $URI.Douyu -UseBasicParsing | Select-Object -ExpandProperty Content | ConvertFrom-Json
        if ($response.state -eq "NO") {
            Write-Log "$($response.info)" DEBUG
            return "斗鱼直播间$($Script:LiveInfo.Room)没有开播"
        }
        Write-Log "数据抓取成功 开始解析直播源..."
        $script:Stream.Streamer = $response.Rendata.data.nickname
        $temp_link = "http://tx2play1.douyucdn.cn" + ($response.Rendata.link -split "douyucdn.cn")[1]
        $Script:Stream.Link = (($temp_link -split ".flv?")[0] -split "_")[0] + "_4000p.m3u8" # 经测试某些直播源删掉清晰度之后无法播放 因此统一加上4000p的清晰度后缀
        return $null
    }
    elseif ($Script:LiveInfo.Site.ToLower() -eq "huya") {
        $ContentType = "application/x-www-form-urlencoded"
        $UserAgent = "Mozilla/5.0 (Linux; Android 5.0; SM-G900P Build/LRX21T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Mobile Safari/537.36"
        $response = Invoke-WebRequest -URI $URI.Huya -UseBasicParsing -ContentType $ContentType -UserAgent $UserAgent | Select-Object -ExpandProperty Content
        # $stat_info = "{" + ((($response -split "STATINFO")[1] -split "{")[1] -split "};")[0] + "}"
        # $temp_link = [regex]::matches($response, "hasvedio: '(.*\.m3u8).*", "IgnoreCase")
        $live_status = (($response -split "totalCount: '")[1] -split "',")[0]
        if ($live_status -eq "") {
            return "虎牙直播间$($Script:LiveInfo.Room)没有开播"
        }
        Write-Log "数据抓取成功 开始解析直播源..."
        $script:Stream.Streamer = (($response -split "ANTHOR_NICK = '")[1] -split "';")[0]
        $Script:Stream.Link = "http://al.rtmp.huya.com/backsrc/" + ((($response -split "hasvedio: '")[1] -split "_")[0] -split "src/")[1] + ".m3u8"
        return $null
    }
}

function Select-StreamLink {
    Set-Clipboard $Script:Stream.Link
    # Write-Log "直播源解析成功 已复制到剪切板`n将以 $($Choose) 的方式处理直播源`n0弹窗询问 1直接播放 2生成asx文件 3直接退出" DEBUG
    $Choose = $Script:Config.after_get
    if ($Choose -eq 0) {
        $thePrompt = @"
成功从$($Script:Stream.Streamer)直播间（$($Script:LiveInfo.Site)/$($Script:LiveInfo.Room)）获取到直播源 $($Script:Stream.Link)
直播源已经复制到剪切板，使用 Ctrl+V 粘贴。`n
当前预设的播放器为 $($Script:Config.player)`n
点击「是」直接使用本地播放器播放
点击「否」生成.asx文件
点击「取消」结束程序
"@
        $playConfirm = Get-MsgBox -Title "直播源获取成功" -Prompt $thePrompt -Buttons YesNoCancel -Icon Question
        if ($playConfirm -eq 'Yes') {
            $Choose = 1
        }
        elseif ($playConfirm -eq 'No') {
            $Choose = 2
        }
        elseif ($playConfirm -eq 'Cancel') {
            $Choose = 3
        }
    }
    if ($Choose -eq 1) {
        Write-Log "尝试启动本地播放器 $($Script:Config.player)"
        Start-Process $Script:Config.player -Argumentlist $Script:Stream.Link
    }
    elseif ($Choose -eq 2) {
        $asx_content = @"
<asx version=`"3.0`">
    <entry>
        <title>[$($script:LiveInfo.Site)_$($script:LIVE_ROOM_ID)]$($script:Stream.Streamer)</title>
        <ref href=`"" + $($Script:Stream.Link) + "`"/>
    </entry>
</asx>
"@
        $asx_path = "$($Workspace)\live"
        if (!(Test-Path $asx_path)) {
            New-Item -ItemType Directory -Force -Path $asx_path
        }
        $output_path = "$($asx_path)\$($Script:LiveInfo.Site)_$($script:LIVE_ROOM_ID).asx"
        Write-Output $asx_content | Out-File -filepath $output_path
        Write-Log "已生成asx文件 $($output_path)" SUCCESS
    }
    elseif ($Choose -eq 3) {
        Write-Log "选择退出"
    }
}

Write-Log -Level DIVIDER

Write-Log "直播源解析工具 Live Stream-link Source Parsing Tool v$($Version)" NOTICE
Write-Log "Cyanashi 最后更新于 $($Updated)" NOTICE
Write-Log "最新源码 $($Source)" NOTICE
Write-Log "开发日志 https://ews.ink/develop/Get-Stream-Link" NOTICE

Write-Log -Level DIVIDER

if (Read-Config) {
    Write-Log "配置文件读取成功" SUCCESS
}
else {
    Write-Log "程序已终止" ERROR
    # TODO 是否重新生成合法的配置文件
}

Write-Log -Level DIVIDER

Write-Log "当前版本仅支持 斗鱼 虎牙 B站 网易cc" NOTICE
if (-not (Initialize-Input)) {
    do {
        try {
            [ValidatePattern('(?<Site>bilibili|cc\.163|douyu|huya)\b\..*\/\b(?:.*\=)?(?<Room>\w+)')]$Script:Input = Read-Host "请输入正确的直播间地址"
            if (Test-Input $Script:Input) {
                $Script:LiveInfo = $Script:Input | Get-LiveInfo
                Write-Log "开始解析 $($Script:Input)" SUCCESS
            }
        }
        catch { }
    } until ($?)
}

Write-Log -Level DIVIDER

$res = Get-StreamLink
if ($null -eq $res) {
    Write-Log "获取直播源成功 $($Script:Stream.Link)" SUCCESS
    Select-StreamLink
}
else {
    Write-Log "尝试获取直播源失败 $($res) $($Script:Stream.Link)" ERROR
}

Write-Log -Level DIVIDER

# Read-Host "任务已结束 输入回车键退出" | Out-Null
exit