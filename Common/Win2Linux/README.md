# Usage
## Win2Linux Win同步文件到Linux
[PowerShell Script] **Win2Linux.ps1**  
Latest Version: 1.0.3  
Last Updated at: 2020-03-27  

1. 使用文本编辑器打开该脚本文件  
2. 编辑 `$Config` 内容，详见文件内注释  
3. 保存并运行 `.\Win2Linux.ps1` 执行该脚本文件  

## Dependence
使用此脚本之前需要准备好 **cwRsync 客户端**。  
我是在[官网](https://www.rsync.net/resources/howto/windows_rsync.html)下的解压直接用的[绿色版](https://www.rsync.net/resources/binaries/cwRsync_5.4.1_x86_Free.zip)。  

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