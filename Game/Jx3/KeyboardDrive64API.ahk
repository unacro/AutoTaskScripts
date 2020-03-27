/**
 * Author: Cyanashi(imwhtl@gmail.com)
 * Version: 1.0.1
 * Description: APIx64 《剑侠情缘网络版叁》按键脚本 64位按键模拟驱动API
 */

class KeyboardDrive64
{
    __New()
    {
        IfNotExist, %A_LineFile%\..\drive\x64\DD.dll
        {
            RegRead, dd_path, HKLM, SOFTWARE\DD XOFT, path
            if !dd_path
            {
                MsgBox, 4112, 错误, 64位按键模拟驱动未找到！
                return
            } else {
                this.hModule := DllCall("LoadLibrary", "Str", dd_path, "Ptr")
                MsgBox, 4144, 警告, 未在脚本目录下找到64位按键模拟驱动，已使用系统驱动！
            }
        } else {
            this.hModule := DllCall("LoadLibrary", "Str", "drive\x64\DD.dll", "Ptr")
            MsgBox, 4160, 提示, 64位按键模拟驱动加载成功！
        }
    }

    __Delete()
    {
        DllCall("FreeLibrary", "Ptr", this.hModule)
    }

    btn(btn) ;鼠标按键
    {
        return DllCall("DD\DD_btn", "Int", btn)
    }


    mov(x, y) ;鼠标绝对移动
    {
        return DllCall("DD\DD_mov", "Int", x, "Int", y)
    }


    movR(dx, dy) ;鼠标相对移动
    {
        return DllCall("DD\DD_movR", "Int", dx, "Int", dy)
    }


    key(key, flag) ;键盘按键 key:DD专用虚拟键码 flag:按下=1, 放开=2
    {
        return DllCall("DD\DD_key", "Int", key, "Int", flag)
    }


    whl(flag) ;鼠标滚轮 按下=1, 放开=2
    {
        return DllCall("DD\DD_whl", "Int", flag)
    }


    str(str) ;直接输入键盘上的可见字符
    {
        return DllCall("DD\DD_str", "Ptr", &str)
    }

    todc(vkcode) ;虚拟键码转DD键码
    {
        return DllCall("DD\DD_todc", "Int", vkcode)
    }


    MouseMove(hwnd, x, y) ;窗口内鼠标移动 hwnd:窗口句柄, 为0时表示全屏, 等同mov
    {
        return DllCall("DD\DD_MouseMove", "Int", hwnd, "Int", x, "Int", y)
    }

    SnapPic(hwnd, x, y, w, h) ;抓图 hwnd:窗口句柄, 为0时表示全屏 暂时无法使用
    {
        return DllCall("DD\DD_SnapPic", "Int", hwnd, "Int", x, "Int", y, "Int", w, "Int", h)

    }

    PickColor(hwnd, x, y, const:=0) ;窗口内取色 hwnd:窗口句柄, 为0时表示全屏 const:常量始终等于0 暂时无法使用
    {
        return DllCall("DD\DD_PickColor", "Int", hwnd, "Int", x, "Int", y, "Int", const)
    }

    GetActiveWindow() ;取激活窗口句柄 用普通方法无法获取时可用这个函数 暂时无法使用
    {
        return DllCall("DD\DD_GetActiveWindow")
    }
}
