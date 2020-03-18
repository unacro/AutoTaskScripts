/**
 * Author: Cyanashi(imwhtl@gmail.com)
 * Version: 1.0.0
 * Description: Config 《剑侠情缘网络版叁》按键脚本 配置文件
 */

class Jx3Config {

    ; 游戏中的按键设置 [KeyAction 互动键] [KeyMacro 放置一键宏的键位]
    static KEY_BIND := {KeyAction: "=", KeyMacro: "-"}

    ; 循环自动模式的间隔时间 分别为 自动互动间隔 自动按宏间隔 自动点击左键间隔 自动点击右键间隔
    static KEY_AUTO_DELAY := {DelayAction: 600, DelayMacro: 600, DelayClickL: 1000, DelayClickR: 1000}

    ; [开启自动互动] 键位
    static KEY_AUTO_ACTION := "XButton1"

    ; [开启自动一键宏] 键位 sc029即反引号/波浪号[`/~](主键盘数字1左边那个键)
    static KEY_AUTO_MACRO := "sc029|XButton2"

    ; [开启鼠标自动点击] 键位
    static KEY_AUTO_CLICK_L := "End"

    ; [开启鼠标自动点击右键] 键位
    static KEY_AUTO_CLICK_R := "PgDn"

    ; [关闭所有自动模式] 键位
    static KEY_RESET_AUTOMODE := "MButton|ESC|Enter|NumpadEnter|M"

    ; [显示调试信息 / 测试模拟驱动效果] 键位
    static KEY_DEBUG := ["F6", "F7"]

    ; [终止并退出脚本] 键位
    static KEY_QUIT := "F5|F8"

}
