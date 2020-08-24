-------- 罗技鼠标 Lua 常用脚本
-------- Author: Sumi (https://ews.ink)
-------- Version: 0.0.1:1(Alpha)

---- 定义常量
EventMB = {L=1, R=2, M=3, B=4, F=5}; --OnEvent()函数中的 1/2/3 分别是 左/右/中
PressMB = {L=1, M=2, R=3, B=4, F=5}; --PressAndReleaseMouseButton()函数的 1/2/3 分别是 左/中/右
---- 鼠标arg用常量代替 防止使用混淆

---- 设置选项
AutoClickOption = {
    Delay = 20, --鼠标连点延迟 不宜太低 保证模拟点击的真实性都是其次 主要是点击的目标一般需要时间做出反馈
    resolution = 1080, --分辨率高度 默认1080p 且比例为16:9
    {MBtn=PressMB.L, X=960, Y=540, min=5, max=20},
};

---- 按键触发事件 路由函数
function OnEvent(event, arg)
    --do return end; --脚本总开关
    if IsKeyLockOn("scrolllock") then
        --OutputLogMessage("[DEBUG] Scroll Lock is On.\n"); --滚轮锁定开关脚本
        if event == "MOUSE_BUTTON_PRESSED" then
            lockProcess = true;
            --OutputLogMessage("[DEBUG] This script has been running for: %d ms.\n", GetRunningTime());
            --OutputLogMessage("[DEBUG] event = %s, arg = %s.\n", event, arg);
            if arg == EventMB.L then
                --需要 EnablePrimaryMouseButtonEvents(true)
                --鼠标左键的事件监控才会生效
                --OutputLogMessage("[DEBUG] Left Mouse Button Pressed.\n");
            elseif arg == EventMB.R then
                --OutputLogMessage("[DEBUG] Right Mouse Button Pressed.\n");
            elseif arg == EventMB.M then
                --OutputLogMessage("[DEBUG] Middle Mouse Button Pressed.\n");
                runMiddleMouseBtnFunc();
            elseif arg == EventMB.F then
                --OutputLogMessage("[DEBUG] Front Side Mouse Button Pressed.\n");
                runFrontSideMouseBtnFunc();
            elseif arg == EventMB.B then
                --OutputLogMessage("[DEBUG] Back Side Mouse Button Pressed.\n");
                runBackSideMouseBtnFunc();
            end
            lockProcess = false;
        elseif event == "MOUSE_BUTTON_RELEASED" then
            --OutputLogMessage("[DEBUG] <A Mouse Button Released>\n");
        end
    end
end

---- 鼠标中键 处理函数
function runMiddleMouseBtnFunc()
    execAutoClick();
end

---- 鼠标前方侧键 处理函数
function runFrontSideMouseBtnFunc()
    --PressAndReleaseMouseButton(PressMB.L);
    execAutoPressKey();
end

---- 鼠标后方侧键 处理函数
function runBackSideMouseBtnFunc()
end

---- 执行自动按键
function execAutoPressKey()
    OutputLogMessage("[DEBUG] Start to Auto Press Key.\n");
    count = 0;
    repeat
        count = count + 1;
        PressAndReleaseMouseButton(1);
        Sleep(320);
        OutputLogMessage("[DEBUG] Loop timer %d times.\n", count, button);
    until not IsKeyLockOn("scrolllock") or count > 5000 --防止死循环
end

---- 执行自动点击
function execAutoClick()
    for i=1, table.getn(AutoClickOption) do
        converted_x, converted_y = convertResolution(AutoClickOption[i].X, AutoClickOption[i].Y)
        OutputLogMessage("[DEBUG] Will Click (%d, %d).\n", converted_x, converted_y);
        MoveMouseTo(converted_x, converted_y);
        PressAndReleaseMouseButton(AutoClickOption[i].MBtn);
        if AutoClickOption[i].min and AutoClickOption[i].max > AutoClickOption[i].min then
            Sleep(math.random(AutoClickOption[i].min, AutoClickOption[i].max));
        end
        Sleep(AutoClickOption.Delay);
    end
end

---- 换算分辨率(点击坐标系) 默认屏幕比例为16:9
function convertResolution(X, Y)
    return X*65535/(AutoClickOption.resolution/9*16), Y*65535/AutoClickOption.resolution
end
