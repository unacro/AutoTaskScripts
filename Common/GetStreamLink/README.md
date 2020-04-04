# Usage
## GetStreamLink 直播源获取工具
[PowerShell Script] **GetStreamLink.ps1**  
Latest Version: 1.0.6  
Last Updated at: 2020-03-28  

* 直接启动脚本
* 编辑 `config.json` 配置文件后启动  
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