# Usage
## ArchiSteamFarm ASF自动部署脚本
[PowerShell Script] **ArchiSteamFarm.ps1**  
Latest Version: 2.0.2  
Last Updated at: 2020-04-02  

1. 如果你之前已经用过ASF，并且已经有设置好的配置文件了，把你的 config 文件夹和脚本文件放到同一目录下来导入配置到新安装的ASF，文件目录结构如下：  
```
└── ASF相关目录/
  ├── config/ # 默认用来导入的配置文件
  │ ├── ASF.json
  │ ├── yourbot.json
  │ ├── IPC.config
  │ └── ...
  ├── core/ # ArchiSteamFarm 主程序
  │ ├── ArchiSteamFarm.exe
  │ ├── config/ # 运行时实际配置文件
  │ │ ├── ASF.json
  │ │ ├── yourbot.bin
  │ │ ├── yourbot.db
  │ │ ├── yourbot.json
  │ │ └── IPC.config
  │ │ └── ...
  │ └── ...
  ├── ArchiSteamFarm.ps1 # 即此脚本
  ├── ASF-win-x64.zip # ArchiSteamFarm latest 压缩包
  └── ...
```
2. 运行脚本，开袋即食  
3. 如果你是 Win 服务器用户，并且不太了解如何修改为 UTF-8 代码页，那么也许你需要使用 GBK 版本  

> 注意事项：网络问题自行解决 ~~或者使用下面提供的分流下载~~  

### Dependence
#### 此脚本需要
* **Win 服务器用户请特别注意：未对 Windows PowerShell 5.1 以下的版本做过兼容，以后也不会做兼容**  
Windows Server 2012 R2 自带的应该是 4.0，[升级 5.1](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-windows-powershell?view=powershell-6) 需要下载 [Windows Management Framework 5.1](https://www.microsoft.com/en-us/download/details.aspx?id=54616)，版本选择 **Win8.1AndW2K12R2-KB3191564-x64.msu** 即可。  

> 我亲手试过了，是真的。  
> ~~如果愿意折腾还以可以试试 [更前沿的 PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows?view=powershell-6)，前往 [Github 仓库](https://github.com/PowerShell/PowerShell/releases) 下载。~~  

#### ASF 本身需要
[ArchiSteamFarm 是 C# 写的](https://github.com/JustArchiNET/ArchiSteamFarm/wiki/Setting-up-zh-CN#net-core-%E4%BE%9D%E8%B5%96)，runtime 稳定运行需要 [.net Core](https://docs.microsoft.com/en-us/dotnet/core/install/dependencies?tabs=netcore30&pivots=os-windows) 相关依赖。
在 Windows 上就是指 **[Microsoft Visual C++ 2015 Redistributable Update](https://www.microsoft.com/zh-cn/download/details.aspx?id=53587)**。

### Bug
> What's your problem??

![WinServer直接打开报错](https://i.loli.net/2020/04/02/2ZHbXgjrOaIhoFl.png)
只有 Windows Server 会出现这个 BUG：  

即使服务器安装了 PowerShell 5.1，直接双击启动脚本也会报奇怪的错误。
打开左下角「开始菜单」旁边的「服务器管理器」旁边的「PowerShell」再用 `.\脚本.ps1` 的方式启动脚本就没问题。
已知是中文的问题，如果脚本内容全部换成英文就没问题（已测试） ~~也许连GBK格式都不用转了~~，但我不想改了，懒得伺候，将就用吧。

## 分流下载
* [百度网盘](https://pan.baidu.com/s/1c1E-xak-RT4v0gd0mThNOg) `cyan`
* [蓝奏云](https://www.lanzous.com/b00zd6csf) `3wan`