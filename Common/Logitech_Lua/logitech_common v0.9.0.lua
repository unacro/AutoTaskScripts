--------自用罗技Lua脚本
--------Author: Rakuyo (https://ews.ink)
--------Version: 0.9.0:1(Alpha)
--------Todo: 由于单线程只能用取巧的方式实现"同一个键位开关循环函数" 搞清按键事件处理逻辑之后重构为0.9.1

--EnablePrimaryMouseButtonEvents(true); --出于性能上的考虑 罗技默认不响应鼠标左键 可使用此函数取消禁用左键响应
lockProcess = false; --线程锁
enableTimer = false; --定时器使能状态
interruptSignal = false; --中断信号 以为是多线程(按键事件相互独立) 然而并不是 结果思路完全跑偏的产物

--OnEvent()函数中的123分别是左右中
--PressAndReleaseMouseButton()函数的123分别是左中右
--为了防止使用混淆用常量代替
EMB = {L=1, R=2, M=3, B=4, F=5}; --MouseButton onEvent
PMB = {L=1, M=2, R=3, B=4, F=5}; --MouseButton Press and release

--Combo Type: 1-键盘按下, 2-鼠标按下, 3-鼠标移动
Combo = {
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
    delay = 200,
    {type=1, command="A", min=5, max=20},
    --{type=2, command=PMB.L, min=5, max=20},
};

function OnEvent(event, arg) --按键触发事件主函数
    --do return end; --脚本总开关
    if IsKeyLockOn("scrolllock") then
        --OutputLogMessage("[DEBUG] Scroll Lock is On.\n"); --滚轮锁定开关脚本
        if event == "MOUSE_BUTTON_PRESSED" and lockProcess == false then --MOUSE_BUTTON_PRESSED/MOUSE_BUTTON_RELEASED
            interruptSignal = false;
            lockProcess = true;
            --OutputLogMessage("[DEBUG] This script has been running for: %d ms.\n", GetRunningTime());
            --OutputLogMessage("[DEBUG] event = %s, arg = %s.\n", event, arg);
            if arg == EMB.M then
                runScriptMiddle();
            elseif arg == EMB.F then
                runScriptSideFront();
            elseif arg == EMB.B then
                OutputLogMessage("[DEBUG] <BackSideMB PRESSED>    ");
                if enableTimer then
                    OutputLogMessage("enableTimer=true\n");
                    interruptSignal = true;
                else
                    --TODO 由于单线程的原因 enableTimer永远都是false 并没有起到标记的作用
                    OutputLogMessage("enableTimer=false\n");
                    runScriptSideBack();
                end
            end
            lockProcess = false;
        elseif event == "MOUSE_BUTTON_RELEASED" then
            if arg == EMB.B then --and enableTimer
                OutputLogMessage("[DEBUG] <BackSideMB RELEASED>\n\n");
                OutputLogMessage("\n");
            end
        end
    end
end

function runScriptMiddle()
    OutputLogMessage("[DEBUG] Pressed Middle Mouse Button.\n");
end

function runScriptSideFront()
    --OutputLogMessage("[DEBUG] Pressed Up Mouse Button.\n");
    doCombo("B");
    lockProcess = false;
end

function runScriptSideBack()
    if not enableTimer then
        --如果定时器还没启动
        enableTimer = true;
        OutputLogMessage("================================================================\n");
        OutputLogMessage("[DEBUG] >>>>>>>> Start Timer process\n");

        --TODO 尝试捕获MOUSE_BUTTON_RELEASED发出事件
        --但OnEvent()函数是单线程的 [PRESSED]后执行到结束才会发出[RELEASED]事件
        --每次完整点击[Click]事件进入队列按时间顺序执行
        if interruptSignal then
            OutputLogMessage("[DEBUG] Waiting for RELEASED BackSideMouseButton!\n");
        end

        if setTimer(PMB.B) then --此处参数应该是PressMouseButton 因为后续是检查鼠标某个键Pressed中止循环
            OutputLogMessage("[DEBUG] Catch interrupt and end process <<<<<<<<\n");
        else
            --如果不是debug给定时器打断点的话 **永远**跑不到这里
            OutputLogMessage("[DEBUG] Timer task compeleted and process died <<<<<<<<\n");
        end
        enableTimer = false;
        OutputLogMessage("================================================================\n");
    else
        --定时器已经是启动状态了
    end
    lockProcess = false;
end

function doCombo(combo_name)
    --预处理 检查CD 准备执行the combo
    local tc = Combo[combo_name];
    if not tc then
        return;
    end
    local interval = GetRunningTime() - tc.LastTime;
    if not tc.CD or tc.CD == 0 or tc.lastTime == 0 or interval > tc.CD then
        execCombo(combo_name);
    elseif type(Combo[tc.Backup]) == "table" then
        OutputLogMessage("[DEBUG] Combo_%s need cooldown %d ms.\n", combo_name, tc.CD - interval);
        if tc.Backup then
            OutputLogMessage("[DEBUG] As replace, try to execute Combo_%s.\n", tc.Backup);
            doCombo(tc.Backup);
            return;
        end
    else
        OutputLogMessage("[DEBUG] Not found Combo_%s.\n", tc.Backup);
    end
end

function execCombo(combo_name)
    local tc = Combo[combo_name];
    local n = table.getn(tc); --统计子元素里数组的数量 "子元素也是数组"代表该元素是需要触发的按键事件
    for i=1, n do
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

function setTimer(offTrigger)
    local n = table.getn(Timer);
    local count = 0;
    while true do
        count = count + 1;
        if count > 15 then return end --debug 防止死循环
        OutputLogMessage("[DEBUG] Loop timer %d times.\n", count);
        for i=1, n do
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
        if IsMouseButtonPressed(offTrigger) then
            OutputLogMessage("[DEBUG] ======== Catch Second <BackSideMB PRESSED> interrupt!\n", count);
            return true; --捕获按键中断 终止定时器
        end
        Sleep(Timer.delay);
    end
    return false;
end
