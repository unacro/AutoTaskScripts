<##
 # Author: Cyanashi(imwhtl@gmail.com)
 # Version: 1.0.1
 # Last_Updated: 2020-03-27
 # Description: GitUtils 本地调试脚本
 #>

$debug = $false
$script:workspace = Split-Path -Parent $MyInvocation.MyCommand.Definition
$script:commandString = @"
echo "[INFO] Write Command Here 此处输入指令"
echo "[INFO] Support Code Block 支持多行"
"@
<##
 # @func Initialize-WorkingDirectory
 # @desc 初始化工作 在执行$script:commandString前运行
 #>
function Initialize-WorkingDirectory {
    Set-Location $script:workspace
    # 已经将 [工作目录] 切换到 [此脚本所在目录] 下
    # TODO 此函数为初始化工作 此处的代码会在
}
<##
 # @func Invoke-Command
 # @desc 执行设定的指令
 # @param {Boolean} $is_debug 是否为调试模式
 #>
function Invoke-Command {
    [CmdletBinding()]
    param (
        [Boolean]$is_debug = $true
    )
    if ($is_debug) {
        $debugInfo = "[DEBUG] Try to exec this command:`n" + $script:commandString
        Write-Host $debugInfo
    }
    else {
        $command = [scriptblock]::Create($script:commandString)
        & $command
    }
}

Initialize-WorkingDirectory
#$debug = $true
Invoke-Command($debug)