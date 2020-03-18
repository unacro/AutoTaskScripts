/**
 * Author: Cyanashi(imwhtl@gmail.com)
 * Version: 1.0.0
 * Description: Main 《剑侠情缘网络版叁》按键脚本 主要业务逻辑
 */

#Include %A_LineFile%\..\Jx3Config.ahk
#Include %A_LineFile%\..\KeyboardDrive32API.ahk
#Include %A_LineFile%\..\KeyboardDrive64API.ahk
CoordMode, Mouse, Client ; 将命令的坐标模式设置为相对于活动窗口
SetKeyDelay, 20 ; 键盘延时
SetMouseDelay, 20 ; 鼠标延时
global APP := new Jx3Config()
global OS_BIT := 32
global AHK_BIT := 32
KeyQuit := APP.KEY_QUIT ; [终止并退出脚本] 键位
Loop, Parse, KeyQuit, |
{
    OneKey :=  Trim(A_LoopField, "{}")
    Hotkey, ~%OneKey%, Quit
}
if (A_Is64bitOS) {
    OS_BIT := 64
}
if (A_PtrSize = 8) {
    AHK_BIT := 64
    DD := new KeyboardDrive64() ; 64位驱动直接使用即可
} else {
    DD := new KeyboardDrive32() ; 32位驱动需要使用管理员权限启动脚本
}

#IfWinActive, ahk_exe JX3ClientX64.exe
WinGetPos, , , Jx3_Width, Jx3_Height, ahk_exe JX3ClientX64.exe

global ActionStatus := false ; 自动互动 true/false 开启/关闭
global MacroStatus := false ; 自动按宏 true/false 开启/关闭
global ClickStatus := 0 ; 自动鼠标点击 0/1/2/3 关闭/左键/右键/左右键一起
global PauseStatus := false ; 暂停自动功能 true/false 开启/关闭 此变量目前没有用到
global KeyAction := APP.KEY_BIND.KeyAction ; [互动] 键位
global KeyMacro := APP.KEY_BIND.KeyMacro ; [一键宏] 键位
global DelayAction := APP.KEY_AUTO_DELAY.DelayAction ; [自动互动] 按键延迟
global DelayMacro := APP.KEY_AUTO_DELAY.DelayMacro ; [自动一键宏] 按键延迟
global DelayClickL := APP.KEY_AUTO_DELAY.DelayClickL ; [自动左键] 按键延迟
global DelayClickR := APP.KEY_AUTO_DELAY.DelayClickR ; [自动右键] 按键延迟
global KeyAutoAction := APP.KEY_AUTO_ACTION ; [自动互动] 键位
global KeyAutoMacro := APP.KEY_AUTO_MACRO ; [自动按宏] 键位
global KeyAutoClickL := APP.KEY_AUTO_CLICK_L ; [自动左击] 键位
global KeyAutoClickR := APP.KEY_AUTO_CLICK_R ; [自动右击] 键位
global KeyResetAutoMode := APP.KEY_RESET_AUTOMODE ; [重置自动模式] 键位
global KeyDebugA := APP.KEY_DEBUG[1] ; [显示调试信息] 键位
global KeyDebugB := APP.KEY_DEBUG[2] ; [测试模拟驱动效果] 键位

; 读取配置文件设置的键位并绑定功能
Hotkey, IfWinActive, ahk_exe JX3ClientX64.exe
Loop, Parse, KeyAutoAction, |
{
    OneKey :=  Trim(A_LoopField, "{}") ; 把 Send 参数中发送模拟按键的格式转成热键参数中的按键格式
    Hotkey, ~%OneKey%, KeepAction
}
Loop, Parse, KeyAutoMacro, |
{
    OneKey :=  Trim(A_LoopField, "{}")
    Hotkey, ~%OneKey%, KeepMacro
}
Loop, Parse, KeyAutoClickL, |
{
    OneKey :=  Trim(A_LoopField, "{}")
    Hotkey, %OneKey%, KeepClickL
}
Loop, Parse, KeyAutoClickR, |
{
    OneKey :=  Trim(A_LoopField, "{}")
    Hotkey, %OneKey%, KeepClickR
}
Loop, Parse, KeyResetAutoMode, |
{
    OneKey :=  Trim(A_LoopField, "{}")
    Hotkey, ~%OneKey%, ResetAutoMode
}
Loop, Parse, KeyDebugA, |
{
    OneKey :=  Trim(A_LoopField, "{}")
    Hotkey, %OneKey%, PrintDebugInfo
}
Loop, Parse, KeyDebugB, |
{
    OneKey :=  Trim(A_LoopField, "{}")
    Hotkey, %OneKey%, TestDD
}

; printInitInfo()
; ListVars

~LControl::
~LShift::
~LAlt::
~Z::
    PauseStatus := true
    stopAutoMode()
Return

~LControl Up::
~LShift Up::
~LAlt Up::
~Z Up::
    PauseStatus := false
    execAutoAction()
    execAutoMacro()
    execAutoClick()
Return

#IfWinActive

toDDCode(temp_key_name) {
    global ; 必须加全局变量才能成功传参 就很怪 这里我甚至都没有新开局部变量
    Return DD.todc(GetKeyVK(temp_key_name))
}

forceSend(temp_key) {
    global
    ; 版本 1.1.30.03 手册上写的 if Var is integer 无法通过编译
    ; 修改为 if (Var is integer) 后字符串也能通过判断 真的怪
    if (floor(temp_key) > 0) {
        temp_key_ddcode := temp_key
    } else {
        temp_key_ddcode := toDDCode(temp_key) ; 新开一个临时变量存转换后的DD键码 以空间换时间
    }
    DD.key(temp_key_ddcode, 1)
    DD.key(temp_key_ddcode, 2)
}

TestDD:
    forceSend(KeyAction)
    forceSend(KeyMacro)
    forceSend("d")
    forceSend("d")
Return

printInitInfo() {
    global
    env_tips := "当前操作系统为 " OS_BIT "位`n"
    env_tips .= "当前AHK脚本解释器为 " AHK_BIT "位`n"
    if (A_IsAdmin) {
        admin_level := "已经"
    } else {
        admin_level := "没有"
    }
    env_tips .= "当前AHK脚本 " admin_level " 获得管理员权限"
    MsgBox, 4160, System Info,  %env_tips%
    KeyQuit := APP.KEY_QUIT ; [终止并退出脚本] 键位
    Loop, Parse, KeyQuit, |
    {
        OneKey :=  Trim(A_LoopField, "{}")
        Hotkey, ~%OneKey%, Quit
    }
}

transX(x) {
    global
    Return Jx3_Width * x / 1920
}

transY(y) {
    global
    Return Jx3_Height * y / 1080
}

stopAutoMode() {
    SetTimer, UseAction, off
    SetTimer, UseMacro, off
    SetTimer, UseLMButton, off
    SetTimer, UseRMButton, off
}

execAutoAction() {
    if (ActionStatus && DelayAction > 0) {
        ; MsgBox % "动啊铁奥"
        SetTimer, UseAction, %DelayAction%
    } else {
        ; MsgBox % "别动了铁奥"
        SetTimer, UseAction, off
    }
}

execAutoMacro() {
    if (MacroStatus && DelayMacro > 0) {
        SetTimer, UseMacro, %DelayMacro%
    } else {
        SetTimer, UseMacro, off
    }
}

execAutoClick() {
    if (ClickStatus = 3) {
        SetTimer, UseLMButton, %DelayClickL%
        SetTimer, UseRMButton, %DelayClickR%
    } else if (ClickStatus = 2) {
        SetTimer, UseLMButton, off
        SetTimer, UseRMButton, %DelayClickR%
    } else if (ClickStatus = 1) {
        SetTimer, UseLMButton, %DelayClickL%
        SetTimer, UseRMButton, off
    } else {
        SetTimer, UseLMButton, off
        SetTimer, UseRMButton, off
    }
}

Quit:
    ExitAPP
Return

UseAction:
    ;ControlSend, , {%KeyAction%}, ahk_exe JX3ClientX64.exe
    forceSend(KeyAction)
Return

UseMacro:
    ;ControlSend, , {%KeyMacro%}, ahk_exe JX3ClientX64.exe
    forceSend(KeyMacro)
Return

UseLMButton:
    MouseGetPos, currentX, currentY
    ControlClick, x%currentX% y%currentY%, ahk_exe JX3ClientX64.exe ; Click
Return

UseRMButton:
    MouseGetPos, currentX, currentY
    ControlClick, x%currentX% y%currentY%, ahk_exe JX3ClientX64.exe, , Right ; Click Right
Return

KeepAction:
    ActionStatus := !ActionStatus
    ; Gosub, PrintDebugInfo
    execAutoAction()
Return

KeepMacro:
    MacroStatus := !MacroStatus
    execAutoMacro()
Return

KeepClickL:
    if (Mod(ClickStatus, 2) = 1) {
        ClickStatus -= 1
    } else {
        ClickStatus += 1
    }
    execAutoClick()
Return

KeepClickR:
    if (ClickStatus > 1) {
        ClickStatus -= 2
    } else {
        ClickStatus += 2
    }
    execAutoClick()
Return

ResetAutoMode:
    ActionStatus := false ; 关闭自动互动
    MacroStatus := false ; 关闭自动按宏
    ClickStatus := 0 ; 关闭自动点击
    stopAutoMode()
Return

PrintDebugInfo:
    if (ActionStatus) {
        str := "自动互动 on`n"
    } else {
        str := "自动互动 off`n"
    }
    if (MacroStatus) {
        str .= "自动按宏 on`n"
    } else {
        str .= "自动按宏 off`n"
    }
    if (Mod(ClickStatus, 2) = 1) {
        str .= "自动左键 on`n"
    } else {
        str .= "自动左键 off`n"
    }
    if (ClickStatus > 1) {
        str .= "自动右键 on`n"
    } else {
        str .= "自动右键 off`n"
    }
    str .= "`n游戏中的快捷键设置`n功能互动键为 [" KeyAction "]`n一键宏所在键位为 [" KeyMacro "]"
    MsgBox % str
Return
