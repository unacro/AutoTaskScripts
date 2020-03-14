/**
 * Author：Cyanashi(imwhtl@gmail.com)
 * Version: 1.0.0
 * 按键绑定：
 * 打开或关闭技能面板 除了S的随便哪个键 我是U
 * 强制原地站立 S
 * 强制移动 A
 */

#Include %A_LineFile%\..\Diablo3Config.ahk
WinGetPos, , , D3_Width, D3_Height, 暗黑破坏神III
#IfWinActive, 暗黑破坏神III
CoordMode, Mouse, Client ;将命令的坐标模式设置为相对于活动窗口
SetKeyDelay, 20 ;键盘延时
SetMouseDelay, 20 ;鼠标延时
global App := new Diablo3Config()

global MoveStatus := false ;自动行走 true/false 开启/关闭
global FireStatus := false ;自动开火输出 true/false 开启/关闭
global MapStatus := false ;小地图状态 true/false 开启/关闭
global RMButtonStatus := false ;鼠标右键状态 true/false 按下/弹起

global KeySkill1 := App.KEY_SKILL[1] ; [技能1] 键位
global KeySkill2 := App.KEY_SKILL[2] ; [技能2] 键位
global KeySkill3 := App.KEY_SKILL[3] ; [技能3] 键位
global KeySkill4 := App.KEY_SKILL[4] ; [技能4] 键位
global KeyClear := App.KEY_CLEAR ; [关闭所有打开的窗口] 键位

global FireMode := 1 ;自动开火模式
global DelaySkill1 := App.FIRE_DELAY[FireMode][1]
global DelaySkill2 := App.FIRE_DELAY[FireMode][2]
global DelaySkill3 := App.FIRE_DELAY[FireMode][3]
global DelaySkill4 := App.FIRE_DELAY[FireMode][4]
global DelayLMButton := App.FIRE_DELAY[FireMode][5]
global DelayRMButton := App.FIRE_DELAY[FireMode][6]

transX(x) {
    global
    Return D3_Width * x / 1920
}

transY(y) {
    global
    Return D3_Height * y / 1080
}

global AvailableHundredParagon := Ceil((App.PARAGON+100-700) / 100) ;有多少个可用的100巅峰(按住Ctrl) 向上取整
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


MsgBox, 成功初始化暗黑三窗口`nWidth: %D3_Width%`nHeight: %D3_Height%`n按键已启动

LabelSkill1:
    ;MsgBox % "label skill 1 = " App.KEY_SKILL[1]
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

LabelClear:
    ControlSend, , {%KeyClear%}, 暗黑破坏神III
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
        str .= "地图 off`n"
    }
    str .= "巅峰等级" App.PARAGON "`n"
    For index, value in App.FIRE_DELAY[FireMode]
        str .= str + "Item " index " is '" value "'`n"
    str .= "clear= " KeyClear
    MsgBox % str
}

initSkillKey() {
    DelaySkill1 := App.FIRE_DELAY[FireMode][1]
    DelaySkill2 := App.FIRE_DELAY[FireMode][2]
    DelaySkill3 := App.FIRE_DELAY[FireMode][3]
    DelaySkill4 := App.FIRE_DELAY[FireMode][4]
    DelayLMButton := App.FIRE_DELAY[FireMode][5]
    DelayRMButton := App.FIRE_DELAY[FireMode][6]
    ; tips := "当前按键延迟`n"
    ; tips .= "Item DelaySkill1 is '" DelaySkill1 "'`n"
    ; tips .= "Item DelaySkill2 is '" DelaySkill2 "'`n"
    ; tips .= "Item DelaySkill3 is '" DelaySkill3 "'`n"
    ; tips .= "Item DelaySkill4 is '" DelaySkill4 "'`n"
    ; tips .= "Item DelayLMButton is '" DelayLMButton "'`n"
    ; tips .= "Item DelayRMButton is '" DelayRMButton "'`n"
    ; MsgBox % tips
}

stopAllAction() {
    SetTimer, LabelClear, off
    SetTimer, LabelSkill1, off
    SetTimer, LabelSkill2, off
    SetTimer, LabelSkill3, off
    SetTimer, LabelSkill4, off
    SetTimer, LabelLMButton, off
    SetTimer, LabelRMButton, off
}

resetAllAction() {
    MoveStatus := false ;关闭自动输出
    FireStatus := false ;关闭自动开火
    RMButtonStatus := false ;重置鼠标状态
    stopAllAction()
}

execAutoMove() {
    if (MoveStatus) {
        ;MsgBox % "动啊铁奥"
        SetTimer, LabelClear, off
        SetTimer, LabelSkill1, off
        SetTimer, LabelSkill2, off
        SetTimer, LabelSkill3, off
        SetTimer, LabelSkill4, off
        SetTimer, LabelLMButton, 150
        SetTimer, LabelRMButton, off
    } else {
        ;MsgBox % "别动了铁奥"
        resetAllAction()
    }
}

execAutoFire() {
    if (FireStatus) {
        SetTimer, LabelClear, 150
        ;MsgBox % "开火"
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
    } else {
        ;MsgBox % "停火"
        resetAllAction()
    }
}

XButton2::
~`::
    FireStatus := false
    if (MapStatus) {
        gosub LabelClear
        MapStatus := false
        MoveStatus := true
    } else {
        if (MoveStatus) {
            MoveStatus := false
        } else {
            MoveStatus := true
        }
    }
    ;debug()
    execAutoMove()
Return

XButton1::
    MoveStatus := false
    if (MapStatus) {
        gosub LabelClear
        MapStatus := false
        FireStatus := true
    } else {
        if (FireStatus) {
            FireStatus := false
        } else {
            FireStatus := true
        }
    }
    execAutoFire()
Return

;打开小地图时如果在自动模式则暂停自动模式
~*Tab::
    if (MapStatus) {
        MapStatus := false
        ;gosub LabelClear
        if (MoveStatus) {
            execAutoMove()
        } else if (FireStatus) {
            execAutoFire()
        }
    } else {
        MapStatus := true
        stopAllAction()
    }
Return

;鼠标上滚
~WheelUp::
    ;SendInput {F 1} ; 喝药
    ;切换 自动移动/自动开火
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

;鼠标下滚 终止脚本并回城
~WheelDown::
    resetAllAction()
    SendInput {T 1}
Return

;处理用别的方式关闭小地图
~ESC::
~Space::
    if (MapStatus) {
        MapStatus := false
        if (MoveStatus) {
            execAutoMove()
        } else if (FireStatus) {
            execAutoFire()
        }
    }
Return

;按下鼠标右键不放
~*RButton::
    RMButtonStatus = true
    stopAllAction()
Return

;松开鼠标右键
*RButton Up::
    RMButtonStatus = false
    if (MoveStatus) {
        execAutoMove()
    } else if (FireStatus) {
        execAutoFire()
    }
Return

~F4::
    debug()
Return

~Enter:: ;对话输入框
~T:: ;回城
~B::
~S:: ;技能
~U::
~I:: ;背包
~M:: ;世界地图
~F3:: ;雷电宏
    resetAllAction()
Return

;切巅峰 主属性模式
PgUp::
    gosub LabelClear ;关闭所有界面
    SendInput {p 1} ;打开巅峰界面
    Click %ParagonResetX%, %ParagonResetY% ;[重置]按钮位置
    Sleep, 150
    SendInput {Control Down} ;按下Ctrl键不放
    SendInput {Click %ParagonLevelX%, %ParagonLevelY3%} ;移速位置
    SendInput {Click %ParagonLevelX%, %ParagonLevelY4%} ;能量上限位置
    SendInput {Click %ParagonLevelX%, %ParagonLevelY1% %AvailableHundredParagon%} ;主属性位置
    SendInput {Control Up} ;松开Ctrl键
    Click %ParagonAcceptX%, %ParagonAcceptY% ;[接受]按钮位置
Return

;切巅峰 体能模式
PgDn::
    gosub LabelClear ;关闭所有界面
    SendInput {p 1} ;打开巅峰界面
    Click %ParagonResetX%, %ParagonResetY% ;[重置]按钮位置
    Sleep, 150
    SendInput {Control Down} ;按下Ctrl键不放
    SendInput {Click %ParagonLevelX%, %ParagonLevelY3%} ;移速位置
    SendInput {Click %ParagonLevelX%, %ParagonLevelY4%} ;能量上限位置
    SendInput {Click %ParagonLevelX%, %ParagonLevelY2% %AvailableHundredParagon%} ;体能位置
    SendInput {Control Up} ;松开Ctrl键
    Click %ParagonAcceptX%, %ParagonAcceptY% ;[接受]按钮位置
Return

;赌血岩 一键买满背包
Up::
    Send {RButton 30}
Return

;忽略提示框直接确认(快速分解/快速萃取)
Down::
    SendInput {Lbutton 1}
    Send {Enter 1}
Return

Home::SendInput {G 1} ;插旗子
End::ESC

;自动修理并分解蓝白
MButton::
Left::
    resetAllAction()
    Click %SmithTagX%, %SmithRepairTagY% ;右侧[修复]按钮位置(520,610)
    Click %SmithFixAllX%, %SmithFixAllY% ;修复[所有物品]按钮位置(260,595)
    Click %SmithTagX%, %SmithBreakTagY% ;右侧[分解]按钮位置(520,485)
    Click %SmithBreakYellowX%, %SmithBreakY% ;[分解所有稀有装备]按钮位置(385,290)
    Send {Enter 1} ;确认分解所有稀有装备
    Click %SmithBreakBlueX%, %SmithBreakY% ;[分解所有魔法装备]按钮位置(320,290)
    Send {Enter 1} ;确认分解所有魔法装备
    Click %SmithBreakWhiteX%, %SmithBreakY% ;[分解所有普通装备]按钮位置(252,290)
    Send {Enter 1} ;确认分解所有普通装备
    Send {Enter 1} ;重复确认分解所有普通装备
    Click %SmithBreakClickX%, %SmithBreakY% ;[分解]按钮位置(165,290)
    Click %NearInventoryX%, %NearInventoryY% ;背包边框附近位置(1420,540)
Return

;快速附魔
Right::
    SendInput {Click %EnchantX%, %EnchantChooseY%} ;选中原属性
    Sleep, 150
    SendInput {Click %EnchantX%, %EnchantAcceptY%} ;选择属性
    Sleep, 150
    SendInput {Click %EnchantX%, %EnchantAcceptY%} ;替换属性
    Sleep, 150
    SendInput {Click %EnchantX%, %EnchantChooseY%} ;选中原属性
Return

Numpad0 & Numpad1::
    FireMode := 1
    initSkillKey()
    execAutoFire()
Return
Numpad0 & Numpad2::
    FireMode := 2
    initSkillKey()
    execAutoFire()
Return
Numpad0 & Numpad3::
    FireMode := 3
    initSkillKey()
    execAutoFire()
Return

#IfWinActive

~F5::
    ExitApp
Return
