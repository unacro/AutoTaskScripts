# 绝对 绝对 绝对不要空置 Read-Host 当作「按回车键继续」

function Get-False {
    # 所以我两个月前写都知道随便起个 $nil 变量来用来捕获输入并置空
    # 今天为什么就忘了 浪费了一晚上的时间
    $debug = 0
    if ($debug) {
        Read-Host "What the FUCK is this"
    }
    else {
        Read-Host "Never mind. Whatever" | Out-Null
    }
    $a_false = [Boolean]$false
    Write-Host "[Debug] 在 Get-False 函数里: 此时 $($a_false) 的类型还是 $($a_false.GetType().Name) 。" -ForegroundColor Yellow
    return $a_false
}

$just_a_false = Get-False
Write-Host "[Debug] 出了 Get-False 函数: 此时 $($just_a_false) 的类型已经变成 $($just_a_false.GetType().Name) 了。" -ForegroundColor Yellow

if ($just_a_false -eq $false) {
    Write-Host "[正常显示] $($just_a_false.GetType().Name) $($just_a_false) 不是 $($false)，所以不会进这个判断。" -ForegroundColor Green
}
elseif ($just_a_false -ne $false) {
    Write-Host "[永不显示] $($just_a_false.GetType().Name) $($just_a_false) 也是 $($false)，所以也不会进这个判断。" -ForegroundColor Gray
}
else {
    Write-Host "[异常显示] $($just_a_false.GetType().Name) $($just_a_false) 就是薛定谔的 $($false)。" -ForegroundColor Red
}

if ($just_a_false) {
    Write-Host "[异常显示] 并且作为 $($just_a_false.GetType().Name) 类型的 $($just_a_false) 算是逻辑 1，可以进入 if 判断" -ForegroundColor Red
}

[Console]::Readkey() | Out-Null
exit
