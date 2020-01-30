$script:ROOT_PATH = Split-Path -Parent $MyInvocation.MyCommand.Definition
$script:METAINFO
$script:PLAYER
$script:DEFAULT
$script:LIVE_URL
$script:LIVE_SITE
$script:LIVE_ROOM_ID
$script:LIVE_STREAMER
$script:LIVE_INFO
function Read-UnicodeString {
    [CmdletBinding()]
    param (
        [String]$UnicodeString
    )
    $zh_cn = [regex]::Replace($UnicodeString, '\\u[0-9-a-f]{4}', { param($char); [char][int]($char.Value.Replace('\u', '0x')) })
    return $zh_cn
}
function Write-Log {
    [CmdletBinding()]
    param (
        [String]$Content,
        [String]$Level = "INFO"
    )
    $curtime = Get-Date
    $Content = $Content.Replace("`n", "`n                              ")
    $log = Read-UnicodeString "[$($curtime)] $($Level) | $($Content)"
    if ($Level.ToUpper() -eq "DEBUG") {
        Write-Host $log -ForegroundColor White
    }
    elseif ($Level.ToUpper() -eq "INFO") {
        Write-Host $log -ForegroundColor Cyan
    }
    elseif ($Level.ToUpper() -eq "WARN") {
        Write-Host $log -ForegroundColor Yellow
    }
    elseif ($Level.ToUpper() -eq "ERROR") {
        Write-Host $log -ForegroundColor Red
    }
    elseif ($Level.ToUpper() -eq "DIVIDER") {
        # Black, DarkBlue, DarkGreen, DarkCyan, DarkRed, DarkMagenta, DarkYellow, Gray, DarkGray, Blue, Green, Cyan, Red, Magenta, Yellow, White
        Write-Host "****************************************************************************************************" -ForegroundColor Gray
    }
}
function Read-Config {
    [CmdletBinding()]
    param (
        [Boolean]$first = $true
    )
    # 尝试读取配置文件
    Write-Log "\u5c1d\u8bd5\u8bfb\u53d6\u914d\u7f6e\u6587\u4ef6"
    $config_path = $script:ROOT_PATH + "\config.xml"
    if (Test-Path $config_path) {
        # 配置文件读取成功
        Write-Log "\u914d\u7f6e\u6587\u4ef6\u8bfb\u53d6\u6210\u529f"
        $xml_data = [xml](Get-Content $config_path)
        $script:METAINFO = $xml_data.config.metainfo
        $script:PLAYER = $xml_data.config.player.path
        if ($null -ne $script:PLAYER) {
            $script:PLAYER = [String]$script:PLAYER.Replace(" ", "")
        }
        $script:DEFAULT = $xml_data.config.default.url
    }
    else {
        # 读取失败 尝试初始化配置文件
        Write-Log "\u8bfb\u53d6\u5931\u8d25 \u5c1d\u8bd5\u521d\u59cb\u5316\u914d\u7f6e\u6587\u4ef6" WARN
        $xml_writer = New-Object System.XMl.XmlTextWriter($config_path, $Null)
        $xml_writer.Formatting = 'Indented'
        $xml_writer.Indentation = 2
        $xml_writer.IndentChar = " "
        $xml_writer.WriteStartDocument()
        $xml_writer.WriteComment(" Live Stream-link Source Parsing Tool ")
        $xml_writer.WriteStartElement('config')
        $xml_writer.WriteAttributeString('version', '1.0.2')
        $xml_writer.WriteStartElement('metainfo')
        $xml_writer.WriteAttributeString('ref', 'https://www.52pojie.cn/thread-1096152-1-1.html')
        $xml_writer.WriteAttributeString('author', 'Rakuyo')
        $xml_writer.WriteElementString('app_version', '1.0.2')
        $xml_writer.WriteElementString('app_updated', '2020.01.29')
        $xml_writer.WriteElementString('never_closed', 'true')
        $xml_writer.WriteEndElement()
        $xml_writer.WriteStartElement('player')
        $xml_writer.WriteElementString('path', 'D:\Program\PotPlayer\PotPlayerMini64.exe')
        $xml_writer.WriteEndElement()
        $xml_writer.WriteStartElement('default')
        $xml_writer.WriteElementString('site', 'douyu')
        $xml_writer.WriteElementString('room_id', ' ')
        $xml_writer.WriteElementString('url', ' ')
        $xml_writer.WriteEndElement()
        $xml_writer.WriteEndDocument()
        $xml_writer.Flush()
        $xml_writer.Close()
        if ($first) {
            Read-Config $false # 确保初始化配置文件之后只会再读一次 防止创建失败后进入死循环
        }
    }
}
[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
Add-Type -AssemblyName System.Windows.Forms
function Get-InputBox {
    [CmdletBinding()]
    param (
        [String]$Prompt = (Read-UnicodeString "Rakuyo \u9996\u53d1\u4e8e\u543e\u7231\u7834\u89e3\u8bba\u575b www.52pojie.cn`n`n
\u8f93\u5165\u60f3\u8981\u89e3\u6790\u76f4\u64ad\u6e90\u7684\u76f4\u64ad\u95f4\u7f51\u5740
\uff08\u5f53\u524d\u7248\u672c\u4ec5\u652f\u6301\u6597\u9c7c\u3001\u864e\u7259\u3001\u0042\u7ad9\uff09"),
        [String]$Title = (Read-UnicodeString "\u76f4\u64ad\u6e90\u83b7\u53d6\u5de5\u5177 v1.0.2 2020.01.29"),
        [String]$DefaultResponse = "https://www.douyu.com/"
    )
    return [Microsoft.VisualBasic.Interaction]::InputBox($Prompt, $Title, $DefaultResponse)
}
function Get-MsgBox {
    param (
        [String]$Prompt = (Read-UnicodeString "\u8bf7\u8f93\u5165\u6b63\u786e\u683c\u5f0f\u7684\u76f4\u64ad\u95f4\u5730\u5740\uff01"),
        [System.Windows.Forms.MessageBoxButtons]$Buttons = [System.Windows.Forms.MessageBoxButtons]::OK,
        [String]$Title = (Read-UnicodeString "\u83b7\u53d6\u76f4\u64ad\u6e90\u5931\u8d25")
        #, [System.Windows.Forms.MessageBoxIcon]$Icon = [System.Windows.Forms.MessageBoxIcon]::None
    )
    #return [System.Windows.Forms.MessageBox]::Show($Prompt, "aaa"+$Title, $Buttons, $Icon)
    return [Microsoft.VisualBasic.Interaction]::MsgBox($Prompt, $Buttons, $Title)
}
function Get-LiveUrl {
    # $input = $null
    # do {
    #     $input = Get-InputBox
    # } while ($null -eq $input -or $input -eq "")
    $input = Get-InputBox
    if ($null -eq $input) {
        Write-Warning "get null" # 很可惜 永远不会进这里
        # TODO 输入容错处理
    }
    elseif ($input -eq "") {
        if ($script:METAINFO.never_closed -eq "true") {
            Write-Log -Level DIVIDER
            $first_use = "VB \u7684 InputBox \u65e0\u8bba\u662f\u300c\u76f4\u63a5\u70b9\u51fb\u53d6\u6d88/\u9000\u51fa\u300d\u8fd8\u662f\u300c\u4fdd\u6301"
            $first_use += "\u8f93\u5165\u6846\u4e3a\u7a7a\u70b9\u51fb\u786e\u5b9a\u300d\u90fd\u4f1a\u8fd4\u56de\u957f\u5ea6\u4e3a\u96f6\u7684\u5b57\u7b26"
            $first_use += "\u4e32`n\u6240\u4ee5\u6ca1\u529e\u6cd5\u5224\u65ad\u7528\u6237\u662f\u8f93\u5165\u9519\u8bef\u8fd8\u662f\u60f3\u8981\u4e3b\u52a8"
            $first_use = Read-UnicodeString ($first_use += "\u9000\u51fa\u7a0b\u5e8f \u56e0\u6b64\u7a7a\u8f93\u5165\u672c\u7a0b\u5e8f\u4e00\u5f8b\u89c6\u4e3a\u9000\u51fa")
            Write-Host $first_use -ForegroundColor Yellow
            $first_use = "\u8fd9\u4e2a\u63d0\u9192\u53ea\u4f1a\u5728\u7b2c\u4e00\u6b21\u4f7f\u7528\u7684\u65f6\u5019\u663e\u793a\uff0c"
            $first_use = Read-UnicodeString ($first_use += "\u4ee5\u540e\u63a7\u5236\u53f0\u7a97\u53e3\u5c06\u968f\u7740\u7a0b\u5e8f\u7ed3\u675f\u4e00\u8d77\u5173\u95ed\u3002")
            Write-Host $first_use -ForegroundColor Cyan
            $config_path = $script:ROOT_PATH + "\config.xml"
            $xml_data = [xml](Get-Content $config_path)
            if ($null -ne $xml_data.SelectSingleNode("//never_closed")) {
                # $xml_data.SelectSingleNode("//never_closed") | ForEach-Object { $_."#text" = $_."#text".Replace("true", "false") }
                $xml_data.config.metainfo.never_closed = "false"
                $xml_data.Save($config_path)
            }
            pause
        }
        exit
    }
    return $input
}
function Get-StreamLink {
    [CmdletBinding()]
    param (
        [String]$url
    )
    if ($url -match ".*=(.*)/?" -and $matches[1].length -gt 0) {
        $script:LIVE_ROOM_ID = $matches[1]
    }
    elseif ($url -match ".*\.com/(.*)/?" -and $matches[1].length -gt 0) {
        $script:LIVE_ROOM_ID = $matches[1]
    }
    else {
        return $null
    }
    # 尝试从直播间抓取直播源...
    Write-Log "\u5c1d\u8bd5\u4ece $($url) \u6293\u53d6\u76f4\u64ad\u6e90..."
    $URI = @{
        Bilibili = "https://api.live.bilibili.com/xlive/web-room/v1/index/getRoomPlayInfo?room_id=$($script:LIVE_ROOM_ID)&play_url=1&mask=1&qn=0&platform=web";
        Douyu    = "https://web.sinsyth.com/lxapi/douyujx.x?roomid=$($script:LIVE_ROOM_ID)";
        Huya     = "https://m.huya.com/$($script:LIVE_ROOM_ID)";
    }
    $script:LIVE_STREAMER = $null
    $script:LIVE_SITE = [regex]::matches($url, "(bilibili|douyu|huya)", "IgnoreCase") | Select-Object -ExpandProperty Value
    if ($script:LIVE_SITE.ToLower() -eq "bilibili") {
        $response = Invoke-WebRequest -URI $URI.Bilibili | Select-Object -ExpandProperty Content | ConvertFrom-Json
        if ($response.data.live_status -eq 0) {
            $script:LIVE_INFO = Read-UnicodeString "B\u7ad9\u76f4\u64ad\u95f4$($script:LIVE_ROOM_ID)\u6ca1\u6709\u5f00\u64ad"
            return ""
        }
        # 数据抓取成功 开始解析直播源...
        Write-Log "\u6570\u636e\u6293\u53d6\u6210\u529f \u5f00\u59cb\u89e3\u6790\u76f4\u64ad\u6e90..."
        $user_info_api = "http://api.bilibili.com/x/space/acc/info?mid=$($response.data.uid)&jsonp=jsonp"
        $streamer_info = Invoke-WebRequest -URI $user_info_api | Select-Object -ExpandProperty Content | ConvertFrom-Json
        $script:LIVE_STREAMER = $streamer_info.data.name
        $temp_stream = "https://cn-hbxy-cmcc-live-01.live-play.acgvideo.com/live-bvc/live_" + ($response.data.play_url.durl[0].url -split "/live_")[1]
        $stream_link = ($temp_stream -split ".flv?")[0].Replace("_1500", "") + ".m3u8"
    }
    elseif ($script:LIVE_SITE.ToLower() -eq "douyu") {
        $response = Invoke-WebRequest -URI $URI.Douyu | Select-Object -ExpandProperty Content | ConvertFrom-Json
        if ($response.state -eq "NO") {
            Write-Log "$($response.info)" DEBUG
            $script:LIVE_INFO = Read-UnicodeString "\u6597\u9c7c\u76f4\u64ad\u95f4$($script:LIVE_ROOM_ID)\u6ca1\u6709\u5f00\u64ad"
            return ""
        }
        Write-Log "\u6570\u636e\u6293\u53d6\u6210\u529f \u5f00\u59cb\u89e3\u6790\u76f4\u64ad\u6e90..."
        $script:LIVE_STREAMER = $response.Rendata.data.nickname
        $temp_stream = "http://tx2play1.douyucdn.cn" + ($response.Rendata.link -split "douyucdn.cn")[1]
        $stream_link = (($temp_stream -split ".flv?")[0] -split "_")[0] + ".m3u8"
    }
    elseif ($script:LIVE_SITE.ToLower() -eq "huya") {
        $ContentType = "application/x-www-form-urlencoded"
        $UserAgent = "Mozilla/5.0 (Linux; Android 5.0; SM-G900P Build/LRX21T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Mobile Safari/537.36"
        $response = Invoke-WebRequest -URI $URI.Huya -ContentType $ContentType -UserAgent $UserAgent | Select-Object -ExpandProperty Content
        # $stat_info = "{" + ((($response -split "STATINFO")[1] -split "{")[1] -split "};")[0] + "}"
        # $temp_stream = [regex]::matches($response, "hasvedio: '(.*\.m3u8).*", "IgnoreCase")
        $live_status = (($response -split "totalCount: '")[1] -split "',")[0]
        if ($live_status -eq "") {
            $script:LIVE_INFO = Read-UnicodeString "\u864e\u7259\u76f4\u64ad\u95f4$($script:LIVE_ROOM_ID)\u6ca1\u6709\u5f00\u64ad"
            return ""
        }
        Write-Log "\u6570\u636e\u6293\u53d6\u6210\u529f \u5f00\u59cb\u89e3\u6790\u76f4\u64ad\u6e90..."
        $script:LIVE_STREAMER = (($response -split "ANTHOR_NICK = '")[1] -split "';")[0]
        $stream_link = "http:" + (($response -split "hasvedio: '")[1] -split "_")[0] + ".m3u8"
    }
    return $stream_link
}
$begin = "\u6ce8\u610f\uff1a\u5c1d\u8bd5\u4ece\u76f4\u64ad\u95f4\u83b7\u53d6\u76f4\u64ad\u6e90\u4e4b\u540e\u7b2c\u4e09\u884c"
$begin += "\u9644\u8fd1\u7684\u5b57\u4f1a\u91cd\u5f71 \u539f\u56e0\u4e0d\u660e`n\u4e3a\u4e86\u5728\u4e0d\u6539\u4ee3"
$begin += "\u7801\u9875\u7684\u524d\u63d0\u4e0b\u8f93\u51fa\u4e2d\u6587\u5230\u63a7\u5236\u53f0 \u6211\u7528\u4e86"
$begin += "\u4e00\u4e2a\u53d6\u5de7\u7684\u65b9\u5f0f`n\u6682\u65f6\u6ca1\u627e\u5230\u66f4\u597d\u7684\u65b9\u6848"
$begin = Read-UnicodeString ($begin += "\u66ff\u4ee3\u4ee5\u4fee\u590d\u8fd9\u4e2abug")
Write-Host $begin
Write-Log -Level DIVIDER
Read-Config
Write-Log -Level DIVIDER
$begin = "\u76f4\u64ad\u6e90\u83b7\u53d6\u5de5\u5177 v1.0.2 \u6700\u540e\u66f4\u65b0\u4e8e2020.01.29`nRakuyo \u9996\u53d1\u4e8e\u543e\u7231\u7834\u89e3\u8bba\u575b "
$begin += "www.52pojie.cn`nbug\u53cd\u9988\u548c\u6539\u5584\u5efa\u8bae\u8bf7\u524d\u5f80 $($script:METAINFO.ref) \u7559\u8a00`n"
$begin += "\u6e90\u7801\u4ed3\u5e93 https://github.com/Cyanashi/AutoTaskScripts/blob/master/Common/GetStreamLink/GetStreamLink.ps1"
$begin = Read-UnicodeString ($begin)
Write-Host $begin -ForegroundColor Cyan
Write-Log -Level DIVIDER
$INPUT_URL = $null
if ($null -eq $args[0]) {
    if ($script:DEFAULT.Length -gt 0) {
        # 检测到设置了默认直播间地址 将直接使用默认直播间
        Write-Log "\u68c0\u6d4b\u5230\u8bbe\u7f6e\u4e86\u9ed8\u8ba4\u76f4\u64ad\u95f4\u5730\u5740\u5c06\u76f4\u63a5\u4f7f\u7528\u9ed8\u8ba4\u76f4\u64ad\u95f4"
        $INPUT_URL = $script:DEFAULT
    }
}
else {
    if (Test-Path $args[0]) {
        $script:PLAYER = $args[0]
        $INPUT_URL = $args[1]
    }
    else {
        $INPUT_URL = $args[0]
        if ($null -ne $args[1]) {
            if (Test-Path $args[1]) {
                $script:PLAYER = $args[1]
            }
        }
    }
}
do {
    if ($null -eq $INPUT_URL) {
        # 请在弹出的对话框中输入要解析的直播间网址
        Write-Log "\u8bf7\u5728\u5f39\u51fa\u7684\u5bf9\u8bdd\u6846\u4e2d\u8f93\u5165\u8981\u89e3\u6790\u7684\u76f4\u64ad\u95f4\u7f51\u5740"
        $INPUT_URL = Get-LiveUrl
    }
    $stream_link = Get-StreamLink $INPUT_URL
    if ($null -eq $stream_link) {
        # 输入的内容不是合法的直播间网址格式
        Write-Log "\u8f93\u5165\u7684\u5185\u5bb9\u4e0d\u662f\u5408\u6cd5\u7684\u76f4\u64ad\u95f4\u7f51\u5740\u683c\u5f0f" WARN
        $nil = Get-MsgBox
        $INPUT_URL = $null
    }
    elseif ($stream_link -eq "") {
        # 从直播间获取直播源失败
        $tips = Read-UnicodeString "\u4ece $($INPUT_URL) \u0020\u83b7\u53d6\u76f4\u64ad\u6e90\u5931\u8d25\uff01`n\u539f\u56e0\uff1a$($script:LIVE_INFO)"
        #$tips += Read-UnicodeString "#"
        Write-Log $tips.Replace("`n", " ") WARN
        $nil = Get-MsgBox -Prompt $tips -ErrorAction Stop
        $INPUT_URL = $null
    }
} while ($null -eq $stream_link -or $stream_link -eq "")
Set-Clipboard $stream_link
# 直播源解析成功 已复制到剪切板
Write-Log "\u76f4\u64ad\u6e90\u89e3\u6790\u6210\u529f \u5df2\u590d\u5236\u5230\u526a\u5207\u677f"
$title = Read-UnicodeString "\u76f4\u64ad\u6e90\u83b7\u53d6\u6210\u529f"
if ($null -ne $script:LIVE_STREAMER) {
    $streamer = "$($script:LIVE_STREAMER)\u7684"
}
$tips = Read-UnicodeString "\u6210\u529f\u4ece$($streamer)\u76f4\u64ad\u95f4\uff08$($INPUT_URL)\uff09`n"
$tips += Read-UnicodeString "\u83b7\u53d6\u5230\u76f4\u64ad\u6e90 $($stream_link)`n"
$tips += Read-UnicodeString "\u76f4\u64ad\u6e90\u5df2\u7ecf\u590d\u5236\u5230\u526a\u5207\u677f\uff0c\u4f7f\u7528 Ctrl+V \u7c98\u8d34\u3002`n`n"
$tips += Read-UnicodeString "\u5f53\u524d\u9884\u8bbe\u7684\u64ad\u653e\u5668\u4e3a $($script:PLAYER)`n"
$tips += Read-UnicodeString "\u662f\u5426\u4f7f\u7528\u672c\u5730\u64ad\u653e\u5668\u76f4\u63a5\u64ad\u653e\uff1f`n`n"
$tips += Read-UnicodeString "\u70b9\u51fb\u300c\u662f\u300d\u76f4\u63a5\u64ad\u653e`n"
$tips += Read-UnicodeString "\u70b9\u51fb\u300c\u5426\u300d\u751f\u6210.asx\u6587\u4ef6`n"
$tips += Read-UnicodeString "\u70b9\u51fb\u300c\u53d6\u6d88\u300d\u7ed3\u675f\u7a0b\u5e8f`n"
$choose = Get-MsgBox -Title $title -Prompt $tips -Buttons YesNoCancel
if ($choose -eq "Yes") {
    # 尝试启动本地播放器
    Write-Log "\u5c1d\u8bd5\u542f\u52a8\u672c\u5730\u64ad\u653e\u5668 $($script:PLAYER)"
    Start-Process $script:PLAYER -Argumentlist $stream_link
}
elseif ($choose -eq "No") {
    # 尝试生成asx文件
    Write-Log "\u5c1d\u8bd5\u751f\u6210asx\u6587\u4ef6"
    if ($null -ne $script:LIVE_STREAMER) {
        $room_name = $script:LIVE_STREAMER
        $room_name += Read-UnicodeString "\u7684\u76f4\u64ad\u95f4"
    }
    $asx_content = "<asx version=`"3.0`">
    <entry>
        <title>[$($script:LIVE_SITE)_$($script:LIVE_ROOM_ID)]$($room_name)</title>
        <ref href=`"" + $stream_link + "`"/>
    </entry>
</asx>"
    $output_path = "$($script:ROOT_PATH)\$($script:LIVE_SITE)_$($script:LIVE_ROOM_ID).asx"
    Write-Output $asx_content | out-file -filepath $output_path
}
elseif ($choose -eq "Cancel") {
    # Nothing to do
}
exit