/**
 * Author: Cyanashi(imwhtl@gmail.com)
 * Version: 1.1.1
 * Description: Main 主要业务逻辑
 */

#Include %A_LineFile%\..\Diablo3Config.ahk
CoordMode, Mouse, Client ; 将命令的坐标模式设置为相对于活动窗口
SetKeyDelay, 20 ; 键盘延时
SetMouseDelay, 20 ; 鼠标延时
global APP := new Diablo3Config()
KeyQuit := APP.KEY_QUIT ; [终止并退出脚本] 键位
Loop, Parse, KeyQuit, |
{
    OneKey :=  Trim(A_LoopField, "{}")
    Hotkey, ~%OneKey%, Quit
}

#IfWinActive, ahk_class D3 Main Window Class
WinGetPos, , , D3_Width, D3_Height, ahk_class D3 Main Window Class

global MoveStatus := false ; 自动行走 true/false 开启/关闭
global FireStatus := false ; 自动开火输出 true/false 开启/关闭
global MapStatus := false ; 小地图状态 true/false 开启/关闭
global RMButtonStatus := false ; 鼠标右键状态 true/false 按下/弹起

global KeySkill1 := APP.KEY_SKILL[1] ; [技能1] 键位
global KeySkill2 := APP.KEY_SKILL[2] ; [技能2] 键位
global KeySkill3 := APP.KEY_SKILL[3] ; [技能3] 键位
global KeySkill4 := APP.KEY_SKILL[4] ; [技能4] 键位
global KeyForceStand := APP.KEY_FORCE_STAND ; [强制原地站立] 键位
global KeyStartMove := APP.KEY_START_MOVE ; [自动移动] 键位
global KeyStartFire := APP.KEY_START_FIRE ; [自动输出] 键位
global KeySwitchAutoMode := APP.KEY_SWITCH_AUTOMODE ; [切换自动模式] 键位
global KeyResetAutoMode := APP.KEY_RESET_AUTOMODE ; [重置自动模式] 键位
global KeyHearthstone := APP.KEY_HEARTHSTONE ; [回城] 键位
global KeySwitchParagonMain := APP.KEY_SWITCH_PARAGON_MAIN ; [切换巅峰到主属性] 键位
global KeySwitchParagonHealth := APP.KEY_SWITCH_PARAGON_HP ; [切换巅峰到体能] 键位
global KeyQuickConfim := APP.KEY_QUICK_CONFIM ; [快速确认] 键位
global KeyQuickEnchant := APP.KEY_QUICK_ENCHANT ; [快速附魔] 键位
global KeyAutoFixAndBreak := APP.KEY_AUTO_FIX_AND_BREAK ; [自动修理并分解蓝白黄] 键位
global KeyAutoCastBloodShard := APP.KEY_AUTO_CAST_BLOODSHARD ; [自动赌血岩] 键位
global KeyClear := APP.KEY_CLEAR ; [关闭所有打开的窗口] 键位
global KeyDebug := APP.KEY_DEBUG ; [显示调试信息] 键位

global FireMode := 1 ; 自动开火模式
global DelaySkill1 := APP.FIRE_MODE_DELAY[FireMode][1]
global DelaySkill2 := APP.FIRE_MODE_DELAY[FireMode][2]
global DelaySkill3 := APP.FIRE_MODE_DELAY[FireMode][3]
global DelaySkill4 := APP.FIRE_MODE_DELAY[FireMode][4]
global DelayLMButton := APP.FIRE_MODE_DELAY[FireMode][5]
global DelayRMButton := APP.FIRE_MODE_DELAY[FireMode][6]

global AvailableHundredParagon := Ceil((APP.PARAGON+100-700) / 100) ; 有多少个可用的100巅峰(按住Ctrl) 向上取整
global ParagonResetX := transX(960)
global ParagonResetY := transY(735)
global ParagonLevelX := transX(1275)
global ParagonLevelY1 := transY(335)
global ParagonLevelY2 := transY(425)
global ParagonLevelY3 := transY(522)
global ParagonLevelY4 := transY(615)
global ParagonAcceptX := transX(830)
global ParagonAcceptY := transY(815)

global SmithTagX := transX(520)
global SmithRepairTagY := transY(610)
global SmithBreakTagY := transY(485)
global SmithFixAllX := transX(260)
global SmithFixAllY := transY(595)
global SmithBreakClickX := transX(165)
global SmithBreakWhiteX := transX(252)
global SmithBreakBlueX := transX(320)
global SmithBreakYellowX := transX(385)
global SmithBreakY := transY(290)
global NearInventoryX := transX(1420)
global NearInventoryY := transY(540)

global EnchantX := transX(260)
global EnchantAcceptY := transY(780)
global EnchantChooseY := transY(395)

; 读取配置文件设置的键位并绑定功能
Hotkey, IfWinActive, ahk_class D3 Main Window Class
Loop, Parse, KeyStartMove, |
{
    OneKey :=  Trim(A_LoopField, "{}") ; 把 Send 参数中发送模拟按键的格式转成热键参数中的按键格式
    Hotkey, ~%OneKey%, DoMove
}
Loop, Parse, KeyStartFire, |
{
    OneKey :=  Trim(A_LoopField, "{}")
    Hotkey, ~%OneKey%, DoFire
}
Loop, Parse, KeySwitchAutoMode, |
{
    OneKey :=  Trim(A_LoopField, "{}")
    Hotkey, ~%OneKey%, SwitchAutoMode
}
Loop, Parse, KeyResetAutoMode, |
{
    OneKey :=  Trim(A_LoopField, "{}")
    Hotkey, ~%OneKey%, ResetAutoMode
}
Loop, Parse, KeyHearthstone, |
{
    OneKey :=  Trim(A_LoopField, "{}")
    Hotkey, ~%OneKey%, UseHearthstone
}
Loop, Parse, KeySwitchParagonMain, |
{
    OneKey :=  Trim(A_LoopField, "{}")
    Hotkey, ~%OneKey%, SwitchParagonMain
}
Loop, Parse, KeySwitchParagonHealth, |
{
    OneKey :=  Trim(A_LoopField, "{}")
    Hotkey, ~%OneKey%, SwitchParagonHealth
}
Loop, Parse, KeyQuickConfim, |
{
    OneKey :=  Trim(A_LoopField, "{}")
    Hotkey, ~%OneKey%, QuickConfim
}
Loop, Parse, KeyQuickEnchant, |
{
    OneKey :=  Trim(A_LoopField, "{}")
    Hotkey, ~%OneKey%, QuickEnchant
}
Loop, Parse, KeyAutoFixAndBreak, |
{
    OneKey :=  Trim(A_LoopField, "{}")
    Hotkey, ~%OneKey%, AutoFixAndBreak
}
Loop, Parse, KeyAutoCastBloodShard, |
{
    OneKey :=  Trim(A_LoopField, "{}")
    Hotkey, ~%OneKey%, AutoCastBloodShard
}
Loop, Parse, KeyClear, |
{
    OneKey :=  Trim(A_LoopField, "{}")
    Hotkey, ~%OneKey%, CloseMap
}
Loop, Parse, KeyDebug, |
{
    OneKey :=  Trim(A_LoopField, "{}")
    Hotkey, ~%OneKey%, PrintDebugInfo
}

printInitInfo()
; ListVars

~Numpad0 & Numpad1::
    FireMode := 1
    initSkillDelay()
    execAutoFire()
Return

~Numpad0 & Numpad2::
    FireMode := 2
    initSkillDelay()
    execAutoFire()
Return

~Numpad0 & Numpad3::
    FireMode := 3
    initSkillDelay()
    execAutoFire()
Return

; 按下鼠标右键不放
~*RButton::
    if (!MapStatus) {
        if (MoveStatus or FireStatus) {
            RMButtonStatus = true
            stopAutoMode()
        }
    }
Return

; 松开鼠标右键
*RButton Up::
    if (!MapStatus) {
        RMButtonStatus = false
        if (MoveStatus) {
            execAutoMove()
        } else if (FireStatus) {
            execAutoFire()
        }
    }
Return

; 打开小地图时如果在自动模式则暂停自动模式
~*Tab::
    if (MapStatus) {
        MapStatus := false
        ; Gosub, UseClear
        if (MoveStatus) {
            execAutoMove()
        } else if (FireStatus) {
            execAutoFire()
        }
    } else {
        MapStatus := true
        stopAutoMode()
    }
Return

; 处理用别的方式关闭小地图
~ESC::
    Gosub, CloseMap
Return

#IfWinActive

hasValue(haystack, needle) {
    if(!isObject(haystack))
        return false
    if(haystack.Length()==0)
        return false
    for k,v in haystack
        if(v==needle)
            return true
    return false
}

printInitInfo() {
    global
    if (D3_Width > 0) {
        MsgBox, [Info] 成功初始化暗黑三游戏进程`n窗口宽度: %D3_Width%`n窗口高度: %D3_Height%`n`n按键已启动
    } else {
        MsgBox, [Info] 未获取到暗黑三游戏进程
    }
}

transX(x) {
    global
    Return D3_Width * x / 1920
}

transY(y) {
    global
    Return D3_Height * y / 1080
}

initSkillDelay() {
    DelaySkill1 := APP.FIRE_MODE_DELAY[FireMode][1]
    DelaySkill2 := APP.FIRE_MODE_DELAY[FireMode][2]
    DelaySkill3 := APP.FIRE_MODE_DELAY[FireMode][3]
    DelaySkill4 := APP.FIRE_MODE_DELAY[FireMode][4]
    DelayLMButton := APP.FIRE_MODE_DELAY[FireMode][5]
    DelayRMButton := APP.FIRE_MODE_DELAY[FireMode][6]
}

stopAutoMode() {
    Gosub, EndPressSkill
    SetTimer, UseClear, off
    SetTimer, UseSkill1, off
    SetTimer, UseSkill2, off
    SetTimer, UseSkill3, off
    SetTimer, UseSkill4, off
    SetTimer, UseLMButton, off
    SetTimer, UseRMButton, off
}

execAutoMove() {
    if (MoveStatus) {
        ; MsgBox % "动啊铁奥"
        Gosub, EndPressSkill
        SetTimer, UseClear, off
        SetTimer, UseSkill1, off
        SetTimer, UseSkill2, off
        SetTimer, UseSkill3, off
        SetTimer, UseSkill4, off
        SetTimer, UseLMButton, 150
        SetTimer, UseRMButton, off
    } else {
        ; MsgBox % "别动了铁奥"
        Gosub, ResetAutoMode
    }
}

execAutoFire() {
    if (FireStatus) {
        Gosub, StartPressSkill
        SetTimer, UseClear, 150
        ; MsgBox % "开火"
        if (DelaySkill1 > 0) {
            SetTimer, UseSkill1, %DelaySkill1%
        } else {
            SetTimer, UseSkill1, off
        }
        if (DelaySkill2 > 0) {
            SetTimer, UseSkill2, %DelaySkill2%
        } else {
            SetTimer, UseSkill2, off
        }
        if (DelaySkill3 > 0) {
            SetTimer, UseSkill3, %DelaySkill3%
        } else {
            SetTimer, UseSkill3, off
        }
        if (DelaySkill4 > 0) {
            SetTimer, UseSkill4, %DelaySkill4%
        } else {
            SetTimer, UseSkill4, off
        }
        if (DelayLMButton > 0) {
            SetTimer, UseLMButton, %DelayLMButton%
        } else {
            SetTimer, UseLMButton, off
        }
        if (DelayRMButton > 0) {
            SetTimer, UseRMButton, %DelayRMButton%
        } else {
            SetTimer, UseRMButton, off
        }
    } else {
        ; MsgBox % "停火"
        Gosub, ResetAutoMode
    }
}

Quit:
    ExitApp
Return

UseSkill1:
    ControlSend, , {%KeySkill1%}, ahk_class D3 Main Window Class
Return

UseSkill2:
    ControlSend, , {%KeySkill2%}, ahk_class D3 Main Window Class
Return

UseSkill3:
    ControlSend, , {%KeySkill3%}, ahk_class D3 Main Window Class
Return

UseSkill4:
    ControlSend, , {%KeySkill4%}, ahk_class D3 Main Window Class
Return

UseClear:
    ControlSend, , {%KeyClear%}, ahk_class D3 Main Window Class
Return

UseLMButton:
    MouseGetPos, currentX, currentY
    ControlClick, x%currentX% y%currentY%, ahk_class D3 Main Window Class, , , , NA ; Click
Return

UseRMButton:
    MouseGetPos, currentX, currentY
    ControlClick, x%currentX% y%currentY%, ahk_class D3 Main Window Class, , Right, , NA ; Click Right
Return

StartPressSkill:
    if (hasValue(APP.FIRE_MODE_DELAY[FireMode], 0)) {
        ControlSend, , {%KeyForceStand% Down}, ahk_class D3 Main Window Class
    }
    if (DelaySkill1 = 0) {
        ControlSend, , {%KeySkill1% Down}, ahk_class D3 Main Window Class
    }
    if (DelaySkill2 = 0) {
        ControlSend, , {%KeySkill2% Down}, ahk_class D3 Main Window Class
    }
    if (DelaySkill3 = 0) {
        ControlSend, , {%KeySkill3% Down}, ahk_class D3 Main Window Class
    }
    if (DelaySkill4 = 0) {
        ControlSend, , {%KeySkill4% Down}, ahk_class D3 Main Window Class
    }
    if (DelayLMButton = 0) {
        SendInput, {Click Down}
    }
    if (DelayRMButton = 0) {
        SendInput, {Click Right Down}
    }
Return

EndPressSkill:
    if (hasValue(APP.FIRE_MODE_DELAY[FireMode], 0)) {
        ControlSend, , {%KeyForceStand% Up}, ahk_class D3 Main Window Class
    }
    if (DelaySkill1 = 0) {
        ControlSend, , {%KeySkill1% Up}, ahk_class D3 Main Window Class
    }
    if (DelaySkill2 = 0) {
        ControlSend, , {%KeySkill2% Up}, ahk_class D3 Main Window Class
    }
    if (DelaySkill3 = 0) {
        ControlSend, , {%KeySkill3% Up}, ahk_class D3 Main Window Class
    }
    if (DelaySkill4 = 0) {
        ControlSend, , {%KeySkill4% Up}, ahk_class D3 Main Window Class
    }
    if (DelayLMButton = 0) {
        SendInput, {Click Up}
    }
    if (DelayRMButton = 0) {
        SendInput, {Click Right Up}
    }
Return

DoMove:
    FireStatus := false
    if (MapStatus) {
        Gosub, UseClear
        MapStatus := false
        MoveStatus := true
    } else if (MoveStatus) {
        MoveStatus := false
    } else {
        MoveStatus := true
    }
    ; Gosub, PrintDebugInfo
    execAutoMove()
Return

DoFire:
    MoveStatus := false
    if (MapStatus) {
        Gosub, UseClear
        MapStatus := false
        FireStatus := true
    } else if (FireStatus) {
        FireStatus := false
    } else {
        FireStatus := true
    }
    execAutoFire()
Return

; 切换 自动移动/自动开火
SwitchAutoMode:
    ; SendInput {F 1} ; 喝药
    if (MoveStatus) {
        MoveStatus := false
        FireStatus := true
        execAutoFire()
    } else if (FireStatus) {
        FireStatus := false
        MoveStatus := true
        execAutoMove()
    }
Return

ResetAutoMode:
    MoveStatus := false ; 关闭自动输出
    FireStatus := false ; 关闭自动开火
    RMButtonStatus := false ; 重置鼠标右键状态
    stopAutoMode()
Return

UseHearthstone:
    Gosub, ResetAutoMode
    SendInput {T 1}
Return

; 一键切巅峰 主属性模式
SwitchParagonMain:
    Gosub, UseClear ; 关闭所有界面
    SendInput {p 1} ; 打开巅峰界面
    Click %ParagonResetX%, %ParagonResetY% ; [重置]按钮位置
    Sleep, 150
    SendInput {Control Down} ; 按下Ctrl键不放
    SendInput {Click %ParagonLevelX%, %ParagonLevelY3%} ; 移速位置
    SendInput {Click %ParagonLevelX%, %ParagonLevelY4%} ; 能量上限位置
    SendInput {Click %ParagonLevelX%, %ParagonLevelY1% %AvailableHundredParagon%} ; 主属性位置
    SendInput {Control Up} ; 松开Ctrl键
    Click %ParagonAcceptX%, %ParagonAcceptY% ; [接受]按钮位置
Return

; 一键切巅峰 体能模式
SwitchParagonHealth:
    Gosub, UseClear ; 关闭所有界面
    SendInput {p 1} ; 打开巅峰界面
    Click %ParagonResetX%, %ParagonResetY% ; [重置]按钮位置
    Sleep, 150
    SendInput {Control Down} ; 按下Ctrl键不放
    SendInput {Click %ParagonLevelX%, %ParagonLevelY3%} ; 移速位置
    SendInput {Click %ParagonLevelX%, %ParagonLevelY4%} ; 能量上限位置
    SendInput {Click %ParagonLevelX%, %ParagonLevelY2% %AvailableHundredParagon%} ; 体能位置
    SendInput {Control Up} ; 松开Ctrl键
    Click %ParagonAcceptX%, %ParagonAcceptY% ; [接受]按钮位置
Return

; 忽略提示框直接确认(快速分解/快速萃取)
QuickConfim:
    SendInput {Lbutton 1}
    Send {Enter 1}
Return

; 快速附魔
QuickEnchant:
    SendInput {Click %EnchantX%, %EnchantChooseY%} ; 选中原属性
    Sleep, 150
    SendInput {Click %EnchantX%, %EnchantAcceptY%} ; 选择属性
    Sleep, 150
    SendInput {Click %EnchantX%, %EnchantAcceptY%} ; 替换属性
    Sleep, 150
    SendInput {Click %EnchantX%, %EnchantChooseY%} ; 选中原属性
Return

; 自动修理并分解蓝白黄
AutoFixAndBreak:
    Gosub, ResetAutoMode
    Click %SmithTagX%, %SmithRepairTagY% ; 右侧[修复]按钮位置(520,610)
    Click %SmithFixAllX%, %SmithFixAllY% ; 修复[所有物品]按钮位置(260,595)
    Click %SmithTagX%, %SmithBreakTagY% ; 右侧[分解]按钮位置(520,485)
    Click %SmithBreakYellowX%, %SmithBreakY% ; [分解所有稀有装备]按钮位置(385,290)
    Send {Enter 1} ; 确认分解所有稀有装备
    Click %SmithBreakBlueX%, %SmithBreakY% ; [分解所有魔法装备]按钮位置(320,290)
    Send {Enter 1} ; 确认分解所有魔法装备
    Click %SmithBreakWhiteX%, %SmithBreakY% ; [分解所有普通装备]按钮位置(252,290)
    Send {Enter 1} ; 确认分解所有普通装备
    Send {Enter 1} ; 重复确认分解所有普通装备
    Click %SmithBreakClickX%, %SmithBreakY% ; [分解]按钮位置(165,290)
    Click %NearInventoryX%, %NearInventoryY% ; 背包边框附近位置(1420,540)
Return

; 赌血岩 一键买满背包 单格的物品买不满按两下
AutoCastBloodShard:
    Send {RButton 30}
Return

CloseMap:
    if (MapStatus) {
        MapStatus := false
        if (MoveStatus) {
            execAutoMove()
        } else if (FireStatus) {
            execAutoFire()
        }
    }
Return

PrintDebugInfo:
    if (MoveStatus) {
        str := "移动 on`n"
    } else {
        str := "移动 off`n"
    }
    if (FireStatus) {
        str .= "开火 on`n"
    } else {
        str .= "开火 off`n"
    }
    if (MapStatus) {
        str .= "地图 on`n"
    } else {
        str .= "地图 off`n`n"
    }
    str .= "预设的巅峰等级 = " APP.PARAGON "`n`n"
    For index, value in APP.FIRE_MODE_DELAY[FireMode]
        str .= str + "Item " index " is '" value "'`n"
    str .= "`n[关闭所有打开的窗口]键 = " KeyClear
    MsgBox % str
Return
