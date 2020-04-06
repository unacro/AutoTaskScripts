#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

Workspace="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ScriptVersion="1.0.0"
LastUpdated="2020-04-06"

#=================================================
#   Author: Cyanashi
#   Version: 1.0.0
#   Updated: 2020-04-06
#   Required: CentOS/Debian/Ubuntu
#   Description: 示例描述信息
#   Link: https://github.com/Cyanashi/AutoTaskScripts
#=================================================

echo -e "当前脚本版本 v${ScriptVersion} 当前脚本路径为 ${Workspace}"
echo -e "最后更新时间 ${LastUpdated}"
