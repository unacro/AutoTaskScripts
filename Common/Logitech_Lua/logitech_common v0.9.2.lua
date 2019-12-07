-------- 自用罗技Lua脚本
-------- Author: Rakuyo (https://ews.ink)
-------- Version: 0.9.2:3(Alpha)

---- 功能使用 Tips
---- execAutoClick() 配合常量 AutoClick 实现 自动点击
---- execAutoInput() 配合常量 AutoInput 实现 一键输入字符串
---- setTimer()      配合常量 Timer     实现 开关循环点击
---- doCombo()       配合常量 Combo     实现 一键智能连招

--定义常量
EMB = {L=1, R=2, M=3, B=4, F=5}; --OnEvent()函数中的 123 分别是 左右中
PMB = {L=1, M=2, R=3, B=4, F=5}; --PressAndReleaseMouseButton()函数的 123 分别是 左中右
--鼠标arg用常量代替 防止使用混淆

--客制化定义功能
Combo = { --Key Type: 1-键盘按下, 2-鼠标按下, 3-鼠标移动
    A = {
        CD = 0, --内置冷却时间
        LastTime = 0, --记录上次使用的时间以便计算CD
        Backup = nil, --冷却时的备用方案
        {type=1, command="Q", keep=50, min=5, max=20},
        {type=1, command="A", keep=50, min=5, max=20},
        {type=1, command="Q", keep=50, min=5, max=20},
    },
    B = {
        CD = 5000,
        LastTime = 0,
        Backup = "A",
        {type=1, command="E", keep=50, min=5, max=20},
        {type=1, command="Q", keep=50, min=5, max=20},
        {type=1, command="D", keep=50, min=5, max=20},
        {type=1, command="R", keep=50, min=5, max=20},
    },
};
Timer = {
    Delay = 150, --经测试150左右效果最佳
    --{type=1, command="A", min=5, max=20},
    {type=2, command=PMB.L, min=5, max=20},
};
AutoInput = {
    Delay = 7, --每个字符间的输入延迟
    CaseInsensitive = true,
    Text = "Welcome to Visit My Blog via https://ews.ink. :)\nOr Contact Me with E-mail \"po@ews.ink\" !~",
};
AutoClick = {
    Delay = 20, --鼠标连点延迟 不宜太低 保证模拟点击的真实性都是其次 主要是点击的目标一般需要时间做出反馈
    resolution = 1080, --分辨率高度 默认1080p 且比例为16:9
    {MBtn=PMB.L, X=960, Y=540, min=5, max=20},
};
--AutoInput.Text = "!@#$%^&*()123456789qwertyuiop[]QWERTYUIOP{}"; --debug

--定义全局变量
lockProcess = false; --线程锁
enableTimer = false; --定时器使能状态

--EnablePrimaryMouseButtonEvents(true); --出于性能上的考虑 罗技默认不响应鼠标左键 可使用此函数取消禁用左键响应

--按键触发事件 路由函数
function OnEvent(event, arg)
    --do return end; --脚本总开关
    if IsKeyLockOn("scrolllock") then
        --OutputLogMessage("[DEBUG] Scroll Lock is On.\n"); --滚轮锁定开关脚本
        if event == "MOUSE_BUTTON_PRESSED" and not lockProcess then
            lockProcess = true;
            --OutputLogMessage("[DEBUG] This script has been running for: %d ms.\n", GetRunningTime());
            --OutputLogMessage("[DEBUG] event = %s, arg = %s.\n", event, arg);
            if arg == EMB.L then
                --需要EnablePrimaryMouseButtonEvents(true)
            elseif arg == EMB.R then
                OutputLogMessage("[DEBUG] Right Mouse Button Pressed.\n");
            elseif arg == EMB.M then
                runMiddleMouseBtnFunc();
            elseif arg == EMB.F then
                --OutputLogMessage("[DEBUG] <BackSideMB PRESSED>\n");
                runFrontSideMouseBtnFunc();
            elseif arg == EMB.B then
                runBackSideMouseBtnFunc();
            end
            lockProcess = false;
        elseif event == "MOUSE_BUTTON_RELEASED" then
            if enableTimer then
                enableTimer = false;
                --OutputLogMessage("[DEBUG] <BackSideMB RELEASED>\n\n");
                --OutputLogMessage("\n");
            end
        end
    end
end

--鼠标中键 处理函数
function runMiddleMouseBtnFunc()
    --OutputLogMessage("[DEBUG] Pressed Middle Mouse Button.\n");
    --execAutoClick();
    execAutoInput();
end

--鼠标前方侧键 处理函数
function runFrontSideMouseBtnFunc()
    if enableTimer then
        --定时器已启动
        --本次按键什么都不做 给上次按键提供一个中断信号(按键按下)就够了
    else
        --定时器未启动
        enableTimer = true;
        OutputLogMessage("[DEBUG] >>>>>>>> Start Timer process\n");
        if setTimer(PMB.F) then --此处参数应该是PressMouseButton 因为后续是检查鼠标某个键Pressed中止循环
            OutputLogMessage("[DEBUG] <<<<<<<< Catch interrupt and end process\n");
        else
            --如果不是debug给定时器打断点的话 **永远**跑不到这里
            OutputLogMessage("[DEBUG] <<<<<<<< Timer task compeleted and process died\n");
        end
        --enableTimer = false; --重置定时器放到按键弹起时处理了
    end
end

--鼠标后方侧键 处理函数
function runBackSideMouseBtnFunc()
    doCombo("B");
end

--准备执行预定的连招 预处理Combo(检查CD,若需要,则启动备用连招)
function doCombo(combo_name)
    local tc = Combo[combo_name];
    if not tc then
        return;
    end
    local interval = GetRunningTime() - tc.LastTime;
    if not tc.CD or tc.CD == 0 or tc.lastTime == 0 or interval > tc.CD then
        execCombo(combo_name);
    elseif type(Combo[tc.Backup]) == "table" then
        OutputLogMessage("[DEBUG] Combo_%s need cooldown %d ms. ", combo_name, tc.CD - interval);
        if tc.Backup then
            OutputLogMessage("- As replace, try to execute Combo_%s.\n", tc.Backup);
            doCombo(tc.Backup);
            return;
        end
    else
        OutputLogMessage("[DEBUG] Not found Combo_%s.\n", tc.Backup);
    end
end

--执行预定的连招
function execCombo(combo_name)
    local tc = Combo[combo_name];
    for i=1, table.getn(tc) do --统计子元素里数组的数量 "子元素也是数组"代表该元素是需要触发的按键事件
        if tc[i].type == 1 then
            if tc[i].keep then
                PressKey(tc[i].command);
                Sleep(tc[i].keep);
                ReleaseKey(tc[i].command);
            else
                PressAndReleaseKey(tc[i].command);
            end
            if tc[i].min and tc[i].max > tc[i].min then
                Sleep(math.random(tc[i].min, tc[i].max));
            end
        elseif tc[i].type == 2 then
            if tc[i].keep then
                PressMouseButton(tc[i].command);
                Sleep(tc[i].keep);
                PressMouseButton(tc[i].command);
            else
                PressAndReleaseMouseButton(tc[i].command);
            end
            if tc[i].min and tc[i].max > tc[i].min then
                Sleep(math.random(tc[i].min, tc[i].max));
            end
        elseif tc[i].type == 3 then
            --鼠标移动
        end
    end
    if tc.CD > 0 then
        Combo[combo_name].LastTime = GetRunningTime();
    end
end

--使能定时器
function setTimer(offTrigger)
    local count = 0;
    repeat
        if IsMouseButtonPressed(offTrigger) then
            --OutputLogMessage("[DEBUG] ======== Catch <BackSideMB PRESSED> interrupt!\n", count);
            return true; --捕获按键中断 终止定时器
        end
        for i=1, table.getn(Timer) do
            if Timer[i].type == 1 then
                PressAndReleaseKey(Timer[i].command);
                if Timer[i].min and Timer[i].max > Timer[i].min then
                    Sleep(math.random(Timer[i].min, Timer[i].max));
                end
            elseif Timer[i].type == 2 then
                PressAndReleaseMouseButton(Timer[i].command);
                if Timer[i].min and Timer[i].max > Timer[i].min then
                    Sleep(math.random(Timer[i].min, Timer[i].max));
                end
            elseif tc[i].type == 3 then
                --鼠标移动
            end
        end
        Sleep(Timer.Delay);
        count = count + 1;
        OutputLogMessage("[DEBUG] Loop timer %d times.\n", count);
    until count < 0 --or count > 15 --debug 防止死循环
    return false;
end

--执行自动点击
function execAutoClick()
    for i=1, table.getn(AutoClick) do
        --converted_x, converted_y = convertResolution(AutoClick[i].X, AutoClick[i].Y)
        --OutputLogMessage("[DEBUG] Ready to click (%d, %d).\n", converted_x, converted_y);
        MoveMouseTo(convertResolution(AutoClick[i].X, AutoClick[i].Y))
        PressAndReleaseMouseButton(AutoClick[i].MBtn);
        if AutoClick[i].min and AutoClick[i].max > AutoClick[i].min then
            Sleep(math.random(AutoClick[i].min, AutoClick[i].max));
        end
        Sleep(AutoClick.Delay);
    end
end

--换算分辨率(点击坐标系) 默认屏幕比例为16:9
function convertResolution(X, Y)
    return X*65535/(AutoClick.resolution/9*16), Y*65535/AutoClick.resolution
end

--执行自动输入
function execAutoInput()
    if AutoInput.CaseInsensitive and IsKeyLockOn("capslock") then
        PressAndReleaseKey("capslock");
    end
    for i=1,string.len(AutoInput.Text) do
        letter = string.sub(AutoInput.Text,i,i);
        --OutputLogMessage("%s %s\n", letter, string.upper(letter));
        if tonumber(letter) then
            PressAndReleaseKey(letter);
        elseif letter == " " then
            PressAndReleaseKey("spacebar");
        elseif letter == "\n" then
            PressAndReleaseKey("enter");
        elseif letter == "~" then
            PressAndReleaseKeyWithShift("tilde");
        elseif letter == "!" then
            PressAndReleaseKeyWithShift("1");
        elseif letter == "@" then
            PressAndReleaseKeyWithShift("2");
        elseif letter == "#" then
            PressAndReleaseKeyWithShift("3");
        elseif letter == "$" then
            PressAndReleaseKeyWithShift("4");
        elseif letter == "%" then
            PressAndReleaseKeyWithShift("5");
        elseif letter == "^" then
            PressAndReleaseKeyWithShift("6");
        elseif letter == "&" then
            PressAndReleaseKeyWithShift("7");
        elseif letter == "*" then
            PressAndReleaseKeyWithShift("8");
        elseif letter == "(" then
            PressAndReleaseKeyWithShift("9");
        elseif letter == ")" then
            PressAndReleaseKeyWithShift("0");
        elseif letter == "_" then
            PressAndReleaseKeyWithShift("minus");
        elseif letter == "+" then
            PressAndReleaseKeyWithShift("equal");
        elseif letter == "{" then
            PressAndReleaseKeyWithShift("lbracket");
        elseif letter == "}" then
            PressAndReleaseKeyWithShift("rbracket");
        elseif letter == "|" then
            PressAndReleaseKeyWithShift("backslash");
        elseif letter == ":" then
            PressAndReleaseKeyWithShift("semicolon");
        elseif letter == "\"" then
            PressAndReleaseKeyWithShift("quote");
        elseif letter == "<" then
            PressAndReleaseKeyWithShift("comma");
        elseif letter == ">" then
            PressAndReleaseKeyWithShift("period");
        elseif letter == "?" then
            PressAndReleaseKeyWithShift("slash");
        elseif letter == "`" then
            PressAndReleaseKey("tilde");
        elseif letter == "-" then
            PressAndReleaseKey("minus");
        elseif letter == "=" then
            PressAndReleaseKey("equal");
        elseif letter == "[" then
            PressAndReleaseKey("lbracket");
        elseif letter == "]" then
            PressAndReleaseKey("rbracket");
        elseif letter == "\\" then
            PressAndReleaseKey("backslash");
        elseif letter == ";" then
            PressAndReleaseKey("semicolon");
        elseif letter == "'" then
            PressAndReleaseKey("quote");
        elseif letter == "," then
            PressAndReleaseKey("comma");
        elseif letter == "." then
            PressAndReleaseKey("numperiod");
        elseif letter == "/" then
            PressAndReleaseKey("slash");
        elseif AutoInput.CaseInsensitive and letter == string.upper(letter) then
            PressAndReleaseKeyWithShift(letter);
        else
            PressAndReleaseKey(letter);
        end
        Sleep(AutoInput.Delay);
    end
end

function PressAndReleaseKeyWithShift(key)
    PressKey("lshift");
    PressAndReleaseKey(key);
    ReleaseKey("lshift");
end
