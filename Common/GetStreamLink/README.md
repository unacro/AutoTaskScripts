# Usage
## GetStreamLink 直播源获取工具
[PowerShell Script] **GetStreamLink.ps1**  
Latest Version: 1.1.0  
Last Updated at: 2020-04-06  

* 直接启动脚本
* 编辑 `config.json` 配置文件后启动（没有配置文件先运行一次生成）  
* 复制好直播间地址后启动  
* 用命令行方式启动  
```powershell
.\GetStreamLink.ps1 "播放器路径" "直播间完整地址或房间号"
echo "或者"
.\GetStreamLink.ps1 "直播间完整地址或房间号" "播放器路径"
echo "或者"
.\GetStreamLink.ps1 "直播间完整地址或房间号" # 需要提前在配置文件设置好默认播放器
echo "三者都是可用的"
```

### Config
* **default** 默认使用的直播间，顺便解释一下使用直播间的优先级  
  1. 先检查命令行是否有输入
  2. 剪切板是否有正确格式的直播间网址
  2. 是否配置了默认直播间url地址
  3. 是否配置了默认房间号（如果没有设置直播平台就默认为斗鱼）
  5. 启动脚本的时候以上都没有，要求用户输入
* **after_get** 成功获取直播源后的默认动作，
  * `0` 每次都弹出对话框询问
  * `1` 直接使用设置好的播放器播放
  * `2` 生成asx文件
  * `3` 直接退出（直播源已经复制到剪切板）

> 更多详情见[开发日志](https://ews.ink/develop/Get-Stream-Link/)  

## Other
如果 PowerShell 报错：  
```powershell
无法加载文件 .\my_script.ps1，因为在此系统上禁止运行脚本。有关详细信息，请参阅 https://go.microsoft.com/fwlink/?LinkID=135170 中的 about_Execution_Policies。
    + CategoryInfo          : SecurityError: (:) []，PSSecurityException    
    + FullyQualifiedErrorId : UnauthorizedAccess
```
说明当前 PowerShell 用户的脚本执行策略不允许执行未签名的本地脚本，可以 `Get-ExecutionPolicy` 查询当前的执行权限策略，默认应该是 `Restricted`。  
以下为可选项：  
* **Restricted** 默认的设置，不允许任何script运行
* **AllSigned** 只能运行经过数字证书签名的script
* **RemoteSigned** 运行本地的script不需要数字签名，但运行从网络上下载的script要求数字签名
* **Unrestricted** 允许任何script运行

如果你看过源码之后觉得我的脚本没问题的话，将执行权限策略修改为 `RemoteSigned` 即可。
```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

> 如果修改之后仍然出现此问题说明你运行 `.\my_script.ps1` 的终端应该具有管理员权限  
> `Win + X` 使用管理员权限启动 PowerShell 运行 `Set-ExecutionPolicy RemoteSigned`  