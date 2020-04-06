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

$confirm = Get-MsgBox -Title "在吗" -Prompt "在吗在吗在吗" -Buttons YesNoCancel -Icon Question
if ($confirm -eq 'Yes') {
    Write-Host "选择 是"
}
elseif ($confirm -eq 'No') {
    Write-Host "选择 否"
}
elseif ($confirm -eq 'Cancel') { 
    Write-Host "选择 取消"
}