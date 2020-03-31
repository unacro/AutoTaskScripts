/**
 * Author: Cyanashi(imwhtl@gmail.com)
 * Version: 1.0.0
 * Last_Updated: 2020-03-31
 * Description: GetAVUPData A站VTB数据统计 AcFun Vtuber Idol Statistics
 */

listfile := "list.json"
FormatTime, now, %A_Now%, yyyyMMdd_HHmmss
filename := "AcFun_Vtuber_Data_" now ".csv"

#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

global orderString := ""
global Vtubers := {}

MsgBox, 4160, 获取数据, 准备开始请求数据
FileRead, VtuberListString, *P65001 %listfile%
if not ErrorLevel {
    VtuberListObject := parseJsonString(VtuberListString)
    For index, value in VtuberListObject
        getVtuberInfo(index)
    ; Vtuber := VtuberListObject.Pop()
    Sort, orderString, N R D,
    orderArray := StrSplit(Trim(orderString, ","), ",")
    output := "排名,uid,用户名,粉丝数,简介,头像`n"
    For index, value in orderArray
        output .= index ", " Vtubers[value].uid ", " Vtubers[value].username ", " value ", " Vtubers[value].bio ", " Vtubers[value].avatar "`n"
    FileAppend, %output%, %filename%, UTF-8
    MsgBox, 4160, 获取成功, 全部数据爬取完成, 已保存到 %filename%！
} else {
    MsgBox, 4112, 错误, 读取Vtuber列表失败。请检查同目录下名为 list.json 的文件是否为正确的JSON格式。
}

getVtuberInfo(uid) {
    ua := "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36"
    url := "https://www.acfun.cn/u/" uid ".aspx"
    html_content := getUrlResponse(url, UTF-8, 65001, , , , , ua, 1)
    ; FileDelete, output.txt
    ; FileAppend, %html_content%, output.txt, UTF-8
    fragment := Trim(StrSplit(StrSplit(html_content, "UPUser")[2],"var ")[1], OmitChars := " `t`n=")
    vtb := parseJsonString(fragment)
    orderString .= vtb.followedCount ","
    Vtubers[vtb.followedCount] := {uid:uid, username:vtb.username, bio:StrReplace(StrReplace(vtb.signature, "`n", " "), ",", " "), avatar:vtb.userImg}
    ; MsgBox % Vtubers[vtb.followedCount].username " Completed"
    return
}

; 此函数来自 https://autohotkey.com/board/topic/93300-what-format-to-store-settings-in/#entry588268
parseJsonString(jsonStr){
    SC := ComObjCreate("ScriptControl") 
    SC.Language := "JScript"
    ComObjError(false)
    jsCode =
    (
    function arrangeForAhkTraversing(obj){
        if(obj instanceof Array){
            for(var i=0 ; i<obj.length ; ++i)
                obj[i] = arrangeForAhkTraversing(obj[i]) ;
            return ['array',obj] ;
        }else if(obj instanceof Object){
            var keys = [], values = [] ;
            for(var key in obj){
                keys.push(key) ;
                values.push(arrangeForAhkTraversing(obj[key])) ;
            }
            return ['object',[keys,values]] ;
        }else
        return [typeof obj,obj] ;
    }
    )
    SC.ExecuteStatement(jsCode "; obj=" jsonStr)
    return convertJScriptObjToAhks( SC.Eval("arrangeForAhkTraversing(obj)") )
}

; 此函数来自 https://autohotkey.com/board/topic/93300-what-format-to-store-settings-in/#entry588268
convertJScriptObjToAhks(jsObj){
    if(jsObj[0]="object"){
        obj := {}, keys := jsObj[1][0], values := jsObj[1][1]
        loop % keys.length
            obj[keys[A_INDEX-1]] := convertJScriptObjToAhks( values[A_INDEX-1] )
        return obj
    }else if(jsObj[0]="array"){
        array := []
        loop % jsObj[1].length
            array.insert(convertJScriptObjToAhks( jsObj[1][A_INDEX-1] ))
        return array
    }else
    return jsObj[1]
}

; 此函数来自 https://www.zhihu.com/question/49922890/answer/543680961
getUrlResponse(URL,Charset="",URLCodePage="",Proxy="",ProxyBypassList="",Cookie="",Referer="",UserAgent="",EnableRedirects="",Timeout=-1) {
    ComObjError(0)  ;禁用 COM 错误通告。禁用后，检查 A_LastError 的值，脚本可以实现自己的错误处理
    WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    if (URLCodePage<>"")    ;设置URL的编码
        WebRequest.Option(2):=URLCodePage
    if (EnableRedirects<>"")
        WebRequest.Option(6):=EnableRedirects
    if (Proxy<>"")  ;设置代理服务器。微软的代码 SetProxy() 是放在 Open() 之前的，所以我也放前面设置，以免无效
        WebRequest.SetProxy(2,Proxy,ProxyBypassList)
    WebRequest.Open("GET", URL, true)   ;true为异步获取，默认是false。龟速的根源！！！卡顿的根源！！！
    if (Cookie<>"") ;设置Cookie。SetRequestHeader() 必须 Open() 之后才有效
    {
        WebRequest.SetRequestHeader("Cookie","tuzi")    ;先设置一个cookie，防止出错，见官方文档
        WebRequest.SetRequestHeader("Cookie",Cookie)
    }
    if (Referer<>"")    ;设置Referer
        WebRequest.SetRequestHeader("Referer",Referer)
    if (UserAgent<>"")  ;设置User-Agent
        WebRequest.SetRequestHeader("User-Agent",UserAgent)
    WebRequest.Send()
    WebRequest.WaitForResponse(Timeout) ;WaitForResponse方法确保获取的是完整的响应
    if (Charset="") ;设置字符集
        return,WebRequest.ResponseText()
    else
    {
        ADO:=ComObjCreate("adodb.stream")   ;使用 adodb.stream 编码返回值。参考 http://bbs.howtoadmin.com/ThRead-814-1-1.html
        ADO.Type:=1 ;以二进制方式操作
        ADO.Mode:=3 ;可同时进行读写
        ADO.Open()  ;开启物件
        ADO.Write(WebRequest.ResponseBody())    ;写入物件。注意 WebRequest.ResponseBody() 获取到的是无符号的bytes，通过 adodb.stream 转换成字符串string
        ADO.Position:=0 ;从头开始
        ADO.Type:=2 ;以文字模式操作
        ADO.Charset:=Charset    ;设定编码方式
        return,ADO.ReadText()   ;将物件内的文字读出
    }
}