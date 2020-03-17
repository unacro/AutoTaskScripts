/**
 * Author: Cyanashi(imwhtl@gmail.com)
 * Version: 1.1.0
 * Description: Config 配置文件
 */

class Diablo3Config {
    ; 巅峰等级
    static PARAGON := 1000
    ; 开火模式设置 此处分别设置每组开火模式的 [技能1 技能2 技能3 技能4 鼠标左键 鼠标右键] 每次循环点击的间隔时间
    ; 注意: AHK的时间单位一般也为ms 但不是特别精准 只能大概接近
    ; 比如 Sleep, 600 实际延时有可能是0.5s 也有可能是0.7s 特意写随机数生成器来模拟真实的按键间隔基本没有必要
    ; 游戏中使用 [小键盘0 + 小键盘1/小键盘2/小键盘3] 切换不同模式
    static FIRE_MODE_DELAY := Array([0, 600, 0, 0, 150, 0], [0, 0, 0, 0, 150, 0], [0, 0, 0, 0, 150, 0])
    ; [技能1 技能2 技能3 技能4] 键位
    static KEY_SKILL := ["1", "2", "3", "4"]
    ; [自动移动] 键位 SC029即反引号/波浪号[`/~](主键盘数字1左边那个键)
    static KEY_START_MOVE := "SC029|XButton2"
    ; [自动输出] 键位
    static KEY_START_FIRE := "XButton1"
    ; [切换自动模式] 键位
    static KEY_SWITCH_AUTOMODE := "WheelUp"
    ; [重置自动模式] 键位
    static KEY_RESET_AUTOMODE := "Enter|T|B|S|U|I|M|F3"
    ; [回城] 键位
    static KEY_HEARTHSTONE := "WheelDown"
    ; [切换巅峰等级到主属性] 键位
    static KEY_SWITCH_PARAGON_MAIN := "PgUp"
    ; [切换巅峰等级到体能] 键位
    static KEY_SWITCH_PARAGON_HP := "PgDn"
    ; [快速确认] 键位
    static KEY_QUICK_CONFIM := "Down"
    ; [快速附魔] 键位
    static KEY_QUICK_ENCHANT := "Right"
    ; [自动修理并分解蓝白黄] 键位
    static KEY_AUTO_FIX_AND_BREAK := "MButton|Left"
    ; [自动赌血岩] 键位
    static KEY_AUTO_CAST_BLOODSHARD := "Up"
    ; [关闭所有打开的窗口] 键位
    static KEY_CLEAR := "Space"
    ; [显示调试信息] 键位
    static KEY_DEBUG := "F6"
    ; [终止并退出脚本] 键位
    static KEY_QUIT := "F5|F8"
}
