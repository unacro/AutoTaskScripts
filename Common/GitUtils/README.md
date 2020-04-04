# Usage
## GitUtils 本地调试脚本
[PowerShell Script] **run.ps1**  
Latest Version: 1.0.1  
Last Updated at: 2020-03-27  

1. 使用文本编辑器打开该脚本文件  
2. 编辑 `$script:commandString` 内容  
```powershell
echo "比如常见的博客程序 Hexo / Hugo"
hexo server --debug
echo "或者"
hugo server
```
3. 保存并运行 `.\run.ps1` 执行该脚本文件  

## GitUtils 自动部署脚本
[PowerShell Script] **ci.ps1**  
Latest Version: v1.0.3  
Last Updated at: 2020-04-04  

1. 如果需要自定义请自行编辑并保存该脚本文件  
2. 自行配置仓库自动部署的 Github Action Workflow  
3. 运行 `.\ci.ps1` 执行该脚本文件  
4. 此脚本支持参数，参数会作为commit信息提交，比如 `.\ci.ps1 "这里是带空格 的 commit message"`  

> 配合本仓库的 Win2Linux 脚本使用效果更佳  

举个例子，配置好 `Win2Linux.ps1` 之后把此脚本(`ci.ps1`)的 `$script:commandString` 修改为以下内容：  
```powershell
git add .
git commit -m`"$($commitWithMessage)`"
git push -u origin
git push gitee
hexo clean
hexo generate
.\Win2Linux.ps1
```

> 但仍然推荐使用 Github Action 来进行配置好后一劳永逸的全自动 编译 / 测试 / 部署 流程  

### Warn
由于用 PowerShell 传参时直接输入 `#` 开头的字符串**并不会**被认为是传入的参数 ~~会当成此行命令的注释忽略掉~~。  
因此使用 `.\ci.ps1 fixed #1 bug` 这样的格式只能接收到 `#` 前的 `fixed`，`&`等特殊符号同理。  
如果要在参数中使用类似的特殊符号，依旧需要将参数整体用引号括起来，类似 `.\ci.ps1 "fix #1 a fatal bug"` 或是 `.\ci.ps1 "add some features & some bugs"`。

### Timeline
* 1.0.2 优化了传参方式 之前「附加消息」必须使用引号包含起来 否则只显示第一个空格前的词  
**Before** `.\ci.ps1 我是猪 八戒 的大师兄孙悟空 的拜把兄弟平天大圣牛魔王 的弟弟如意真仙 要打胎吗` >> 你是猪  
**Now** `.\ci.ps1 没 有 问 题 直 接 合 并` >> 没 问 题 就 是 没 问 题  
* 1.0.3 优化了上个版本有时候并没有正确取到对应参数的 bug  

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