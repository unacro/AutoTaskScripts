# AutoTaskScripts
各种自动化脚本

## Usage 食用方法
### Common 通用脚本
#### [Excel2MySQL] 从Excel导入数据到MySQL
好像有个同名软件，不过这种东西总要自己写才能放心用。  
1. 根据自己的情况新建一个名为`config.json`的配置文件，格式参考`config.example.json`填
2. 运行`excel2mysql.py`
3. ~~没了~~ 进入数据库，根据自己的需求详细修改数据表（主要内容已经进来了，怎么揉捏是你的事）

原型：  
自己有个[需求](https://tool.ews.ink/pc-building-simulator.html)要用到PCBS（装机模拟器）的[rank数据](https://1drv.ms/x/s!AgP0NBEuAPQRp9JNWSNJedchtEvZ7Q)，需要从xlsx导数据到mysql，决定自己用python写。  
后来发散思维发现有了这个功能可以干很多事就把专门给PCBS写的重构成比较通用的版本了。  

#### [Logitech_Lua] 罗技Lua脚本
我能想到的、能用罗技的lua做到的、各种游戏一般都用得上的功能基本上都写出来了。  
1. 打开「Logitech 游戏软件」
2. 进入鼠标键位设置界面
3. 右上方选择一个「配置文件」（最好用新建的配置文件，然后右键「配置文件」弹出菜单「设为永久性配置文件」，不想用的时候反勾掉这一项就行了。这样的话万一脚本崩了不会影响太大，开关脚本也方便。如果日常操作用不到脚本更简单，直接新建配置文件绑定到使用脚本的特定程序就好。总之不建议动「默认配置文件」）
4. 右键菜单，点击「编写脚本」打开lua编辑窗口
5. 复制粘贴（不够优雅？下载卡网速卡半天/导入找文件找半天就优雅了吗）
6. 保存即生效

### [Diablo3] 暗黑破坏神3脚本
之前用不知道哪个版本的ahk写的，正在重构。  
（V2之前的语法真的太蠢了……乱到这个程度反而让人生不起气，只觉得想笑）
![AutoHotkey各分支演进图](https://maul-esel.github.io/ahkbook/en/images/versions.png)
……虽然还是ahk，不过是船新版本L2。  
调试环境是Unicode 64位，不考虑别的兼容（也没什么可兼容的），快速迭代中。  
