/**
 * Author: Cyanashi(imwhtl@gmail.com)
 * Version: 1.0.0
 * Description: Debug 调试
 */

#IfWinActive, ahk_exe JX3ClientX64.exe

CoordMode, Mouse, Client ;将命令的坐标模式设置为相对于活动窗口
WinGetPos, , , Jx3_Width, Jx3_Height, ahk_class D3 Main Window Class

; 调试当前鼠标位置
~F4::
    MouseGetPos, currentX, currentY
    tips := "当前屏幕大小 " Jx3_Width " x " Jx3_Height "`n`n"
    tips .= "当前鼠标位置`n"
    tips .= "X = " currentX " (" (currentX/Jx3_Width) "%)`n"
    tips .= "Y = " currentY " (" (currentY/Jx3_Height) "%)`n`n"
    tips .= "换算到 1080p标准尺寸(16:9) 为`n(" Floor(currentX/Jx3_Width*1920) ", " Floor(currentY/Jx3_Height*1080) ")"
    MsgBox % tips
Return

#IfWinActive

; 配合主脚本强制重启脚本 避免 Reload 会出现的部分问题
~F5::
    Sleep, 600
    Run, %A_LineFile%\..\Jx3Main.ahk
Return

; 配合主脚本一键退出所有脚本
~F8::
    ExitApp
Return
