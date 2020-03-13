/**
 * Author：Cyanashi(imwhtl@gmail.com)
 * Version: 1.0.0
 * 按键绑定：
 * 打开或关闭技能面板 除了S的随便哪个键 我是U
 * 强制原地站立 S
 * 强制移动 A
 */

#Include %A_LineFile%\..\Diablo3Config.ahk
#IfWinActive, 暗黑破坏神III
CoordMode, Mouse, Client ;将命令的坐标模式设置为相对于活动窗口
SetKeyDelay, 20 ;键盘延时
SetMouseDelay, 20 ;鼠标延时
global APP := new Diablo3Config()
global AvailableHundredParagon := Ceil((APP.PARAGON+100-700) / 100) ;有多少个可用的100巅峰(按住Ctrl) 向上取整
global KeySkill1 := APP.SKILL_KEY[1]
global KeySkill2 := APP.SKILL_KEY[2]
global KeySkill3 := APP.SKILL_KEY[3]
global KeySkill4 := APP.SKILL_KEY[4]
global FireMode := 1
global DelaySkill1 := APP.FIRE_DELAY[FireMode][1]
global DelaySkill2 := APP.FIRE_DELAY[FireMode][2]
global DelaySkill3 := APP.FIRE_DELAY[FireMode][3]
global DelaySkill4 := APP.FIRE_DELAY[FireMode][4]
global DelayLMButton := APP.FIRE_DELAY[FireMode][5]
global DelayRMButton := APP.FIRE_DELAY[FireMode][6]
global MoveStatus := false ;自动行走 true/false 开启/关闭
global FireStatus := false ;自动开火输出 true/false 开启/关闭
global MapStatus := false ;小地图状态 true/false 开启/关闭
global RMButtonStatus := false ;鼠标右键状态 true/false 按下/弹起
MsgBox % "按键已启动"

LabelSkill1:
    ;MsgBox % "label skill 1 = " APP.SKILL_KEY[1]
    ;TODO 自定义按键绑定
    ControlSend, , {%KeySkill1%}, 暗黑破坏神III
Return

LabelSkill2:
    ControlSend, , {%KeySkill2%}, 暗黑破坏神III
Return

LabelSkill3:
    ControlSend, , {%KeySkill3%}, 暗黑破坏神III
Return

LabelSkill4:
    ControlSend, , {%KeySkill4%}, 暗黑破坏神III
Return

LabelLMButton:
    MouseGetPos, currentX, currentY
    ControlClick, x%currentX% y%currentY%, 暗黑破坏神III ;Click
Return

LabelRMButton:
    MouseGetPos, currentX, currentY
    ControlClick, x%currentX% y%currentY%, 暗黑破坏神III, , Right ;Click Right
Return

debug() {
    if (FireStatus) {
        str := "开火 on`n"
    } else {
        str := "开火 off`n"
    }
    if (MapStatus) {
        str .= "地图 on`n"
    } else {
        str .= "地图 off`n"
    }
    str .= "巅峰等级" APP.PARAGON "`n"
    For index, value in APP.FIRE_DELAY[FireMode]
        str .= str + "Item " index " is '" value "'`n"
    MsgBox % str
}

initSkillKey() {
    DelaySkill1 := APP.FIRE_DELAY[FireMode][1]
    DelaySkill2 := APP.FIRE_DELAY[FireMode][2]
    DelaySkill3 := APP.FIRE_DELAY[FireMode][3]
    DelaySkill4 := APP.FIRE_DELAY[FireMode][4]
    DelayLMButton := APP.FIRE_DELAY[FireMode][5]
    DelayRMButton := APP.FIRE_DELAY[FireMode][6]
    ; tips := "当前按键延迟`n"
    ; tips .= "Item DelaySkill1 is '" DelaySkill1 "'`n"
    ; tips .= "Item DelaySkill2 is '" DelaySkill2 "'`n"
    ; tips .= "Item DelaySkill3 is '" DelaySkill3 "'`n"
    ; tips .= "Item DelaySkill4 is '" DelaySkill4 "'`n"
    ; tips .= "Item DelayLMButton is '" DelayLMButton "'`n"
    ; tips .= "Item DelayRMButton is '" DelayRMButton "'`n"
    ; MsgBox % tips
}

execTimer() {
    if (MapStatus or MoveStatus or !FireStatus) {
        ;MsgBox % "开火 off"
        SetTimer, LabelSkill1, off
        SetTimer, LabelSkill2, off
        SetTimer, LabelSkill3, off
        SetTimer, LabelSkill4, off
        if (MoveStatus) {
            SetTimer, LabelLMButton, 150
        } else {
            SetTimer, LabelLMButton, off
        }
        SetTimer, LabelRMButton, off
    } else {
        ;MsgBox % "开火 on"
        if (DelaySkill1 > 0) {
            SetTimer, LabelSkill1, %DelaySkill1%
        } else {
            SetTimer, LabelSkill1, off
        }
        if (DelaySkill2 > 0) {
            SetTimer, LabelSkill2, %DelaySkill2%
        } else {
            SetTimer, LabelSkill2, off
        }
        if (DelaySkill3 > 0) {
            SetTimer, LabelSkill3, %DelaySkill3%
        } else {
            SetTimer, LabelSkill3, off
        }
        if (DelaySkill4 > 0) {
            SetTimer, LabelSkill4, %DelaySkill4%
        } else {
            SetTimer, LabelSkill4, off
        }
        if (DelayLMButton > 0) {
            SetTimer, LabelLMButton, %DelayLMButton%
        } else {
            SetTimer, LabelLMButton, off
        }
        if (DelayRMButton > 0) {
            SetTimer, LabelRMButton, %DelayRMButton%
        } else {
            SetTimer, LabelRMButton, off
        }
    }
}

stopTimer() {
    MoveStatus := false ;关闭自动输出
    FireStatus := false ;关闭自动开火
    RMButtonStatus := false ;重置鼠标状态
    execTimer()
}

XButton1::
    FireStatus := !FireStatus ;切换开关
    ;debug()
    execTimer() ;进入函数处理判断
Return

XButton2::
~`::
    MoveStatus := !MoveStatus ;切换开关
    ;debug()
    execTimer() ;进入函数处理判断
Return

;打开小地图时如果在自动模式则暂停自动模式
~*Tab::
    if (MapStatus) {
        SendInput {Space 1} ;关闭所有打开的窗口
    }
    MapStatus := !MapStatus
    execTimer()
Return

;按下鼠标右键不放
~*RButton::
    RMButtonStatus = true
    execTimer()
Return

;松开鼠标右键
*RButton Up::
    RMButtonStatus = false
    execTimer()
Return

~Enter:: ;对话输入框
~T:: ;回城
~B::
~S:: ;技能
~U::
~I:: ;背包
~M:: ;世界地图
NumpadIns::
Numpad0::
    stopTimer()
Return

;鼠标上滚 喝药
~WheelUp::
    SendInput {F 1}
Return

;鼠标下滚 终止脚本并回城
~WheelDown::
    stopTimer()
    SendInput {T 1}
Return

NumpadAdd::
F2:: ;切巅峰 主属性模式
/*
    ;考虑到实战可能分不清到底是哪种模式 我把两种模式分开写了 分别放在F2和F3键上
    ;dpsModeParagon := !dpsModeParagon
    ;if (dpsModeParagon=1) ;主属性模式
*/
;{
    SendInput {Space 1} ;关闭所有界面
    SendInput {p 1} ;打开巅峰界面
    Click 960, 735 ;[重置]按钮位置
    Sleep, 150
    SendInput {Control Down} ;按下Ctrl键不放
    SendInput {Click 1275, 522} ;移速位置
    SendInput {Click 1275, 615} ;能量上限位置
    SendInput {Click 1275, 335 %availableHundredPar%} ;主属性位置
    SendInput {Control Up} ;松开Ctrl键
    Click 830, 815 ;[接受]按钮位置
;}
Return
NumpadSub::
F3:: ;切巅峰 体能模式
    SendInput {Space 1} ;关闭所有界面
    SendInput {p 1} ;打开巅峰界面
    Click 960, 735 ;[重置]按钮位置
    Sleep, 150
    SendInput {Control Down} ;按下Ctrl键不放
    SendInput {Click 1275, 522} ;移速位置
    SendInput {Click 1275, 615} ;能量上限位置
    SendInput {Click 1275, 425 %availableHundredPar%} ;体能位置
    SendInput {Control Up} ;松开Ctrl键
    Click 830, 815 ;[接受]按钮位置
Return


;赌血岩 一键买满背包
Up::
    Send {RButton 30}
Return

;自动分解
MButton::
Down::
    Click 520, 610 ;右侧[修复]按钮位置(520,610)
    Click 260, 595 ;修复[所有物品]按钮位置(260,595)
    Click 520, 485 ;右侧[分解]按钮位置(520,485)
    Click 385, 290 ;[分解所有稀有装备]按钮位置(385,290)
    Send {Enter 1} ;确认分解所有稀有装备
    Click 320, 290 ;[分解所有魔法装备]按钮位置(320,290)
    Send {Enter 1} ;确认分解所有魔法装备
    Click 252, 290 ;[分解所有普通装备]按钮位置(252,290)
    Send {Enter 1} ;确认分解所有普通装备
    Send {Enter 1} ;重复确认分解所有普通装备
    Click 165, 290 ;[分解]按钮位置(165,290)
    Click 1420, 540 ;背包边框附近位置(165,290)
Return

;忽略提示框直接确认(快速分解/快速萃取)
Left::
    SendInput {Lbutton 1}
    Send {Enter 1}
Return

Home::SendInput {G 1} ;插旗子
End::ESC

Numpad0 & Numpad1::
    FireMode := 1
    initSkillKey()
    execTimer()
Return
Numpad0 & Numpad2::
    FireMode := 2
    initSkillKey()
    execTimer()
Return
Numpad0 & Numpad3::
    FireMode := 3
    initSkillKey()
    execTimer()
Return

#IfWinActive

~F5::
    ExitApp
Return
