/**
 * Author: Cyanashi(imwhtl@gmail.com)
 * Version: 1.0.0
 * Description:
 *   AHK脚本解释器(AutoHotkey.exe 这里特指 AutoHotkey_L v1 版本 即官网默认下载版本)加载脚本时选择编码的优先级顺序分别为：
 *     1. 若脚本文件开头为字节顺序标记(BOM)，则据其选择相应的编码(UTF-8 BOM 或 UTF-16 BOM)
 *     2. 若解释器命令行中包含了 /CPn 选项，则使用 n 指定的编码
 *     3. 其他情况下，则使用系统默认代码页(一般情况下即 ANSI 编码)
 *
 *   **本仓库所有 .ahk 脚本均以 (不带BOM的)UTF-8 编码编写**
 *   如果使用 ANSI 编码打开，功能基本不会受到影响，但用户交互显示的内容可能会出现乱码
 *   此时可运行此脚本，将 AutoHotKey 的默认代码页设置为 UTF-8 然后重启 AutoHotKey 以修复乱码问题
 */

cmd="%A_AhkPath%" /CP65001 "`%1" `%*
key=AutoHotkeyScript\Shell\Open\Command
if A_IsAdmin
    RegWrite, REG_SZ, HKCR, %key%,, %cmd%
else
    RegWrite, REG_SZ, HKCU, Software\Classes\%key%,, %cmd%
MsgBox Success`n`nCodepage already changed to UTF-8
