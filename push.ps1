<##
 # Author: Cyanashi(imwhtl@gmail.com)
 # Version: 1.0.2
 # Last_Updated: 2020-03-31
 # Description: 一键push
 #>

$debug = $false
$curtime = Get-Date
if ([String]::IsNullOrEmpty($args[0])) {
  $commitWithMessage = "Updated@$($curtime)"
}
else {
  $extraMsg = [String]$args[0]
  For ($i = 1; $i -lt $args.Count; $i++) {
    $extraMsg += " $($args[$i])"
  }
  $commitWithMessage = "Updated@$($curtime) $($extraMsg.Trim())"
}
Write-Output $commitWithMessage
exit
$script:workspace = Split-Path -Parent $MyInvocation.MyCommand.Definition
$script:autoDelete = "" # 需要删除的文件夹写在这里即可 比如 \public
$script:commandString = @"
git add .
git commit -m`"$($commitWithMessage)`"
git push -u origin
git push gitee
"@

<##
 # @func Initialize-WorkingDirectory
 # @desc 初始化工作 在执行$script:commandString前运行
 #>
function Initialize-WorkingDirectory {
  Set-Location $script:workspace
  if (-not [String]::IsNullOrEmpty($script:autoDelete)) {
    $public = $script:workspace + $script:autoDelete
    if (Test-Path $public -and $public -ne $script:workspace) {
      Remove-Item $public -Recurse
    }
  }
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