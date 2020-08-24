#!/usr/bin/env bash
#=================================================
#   Author: Cyanashi
#   Version: 2.0.0
#   Updated: 2020-04-27
#   Required: CentOS/Debian/Ubuntu
#   Description: ArchiSteamFarm 安装管理脚本
#   Link: https://github.com/Cyanashi/AutoTaskScripts
#=================================================
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
Workspace="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ScriptVersion="2.0.0"
LastUpdated="2020-04-27"

function log() {
    typeset -u level
    level="$2"
    if [ $# == 1 ]; then
        level="INFO"
        prefix="\033[37m"
    elif [ $level == "INFO" ]; then
        prefix="\033[37m"
    elif [ $level == "WARN" ]; then
        prefix="\033[1;33m"
    elif [ $level == "ERROR" ]; then
        prefix="\033[1;31m"
    elif [ $level == "FATAL" ]; then
        prefix="\033[1;37;41m"
    elif [ $level == "NOTICE" ]; then
        prefix="\033[1;36m"
    elif [ $level == "SUCCESS" ]; then
        prefix="\033[1;32m"
    elif [ $level == "DEBUG" ]; then
        prefix="\033[7m"
    elif [ $level == "BREAK" ]; then
        prefix="\033[5;7m"
    elif [ $level == "DIVIDER" ]; then
        echo "================================================================"
        return
    else
        level="INFO"
        prefix="\033[37m"
    fi
    echo -e "$prefix[$(date +"%Y-%m-%d %H:%M:%S")] $level | $1\033[0m"
}

log 1 divider

log "ArchiSteamFarm 安装/管理脚本 v${ScriptVersion} 最后更新时间 ${LastUpdated}" notice

if [[ -f /etc/redhat-release ]]; then
    OSVersion="CentOS"
elif [[ -f /etc/debian_version ]]; then
    OSVersion="Debian"
elif cat /etc/issue | grep -q -E -i "debian"; then
    OSVersion="Debian"
elif cat /etc/issue | grep -q -E -i "ubuntu"; then
    OSVersion="Ubuntu"
elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
    OSVersion="CentOS"
elif cat /proc/version | grep -q -E -i "debian"; then
    OSVersion="Debian"
elif cat /proc/version | grep -q -E -i "ubuntu"; then
    OSVersion="Ubuntu"
elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
    OSVersion="CentOS"
else
    OSVersion="Unknown"
fi
if [[ $(getconf LONG_BIT) == "64" ]]; then
    OSBits="64"
else
    OSBits="32"
fi
log "操作系统为 ${OSVersion} x${OSBits} 当前工作目录为 ${Workspace}" notice
if [ $OSVersion == "Unknown" ]; then
    log "未知系统！脚本已终止！" fatal
fi

log 1 divider

installed_count=0
if [ $(yum list installed | grep libcurl | wc -l) != 0 ]; then
    let installed_count+=1
    log "依赖包 libcurl 已安装。"
fi
if [ $(yum list installed | grep libicu | wc -l) != 0 ]; then
    let installed_count+=1
    log "依赖包 libicu 已安装。"
fi
if [ $(yum list installed | grep libkrb5-3 | wc -l) != 0 ]; then
    let installed_count+=1
    log "依赖包 libkrb5-3 已安装。"
fi
if [ $(yum list installed | grep liblttng-ust0 | wc -l) != 0 ]; then
    let installed_count+=1
    log "依赖包 liblttng-ust0 已安装。"
fi
if [ $(yum list installed | grep libssl | wc -l) != 0 ]; then
    let installed_count+=1
    log "依赖包 libssl 已安装。"
fi
if [ $(yum list installed | grep zlib1g | wc -l) != 0 ]; then
    let installed_count+=1
    log "依赖包 zlib1g 已安装。"
fi
if [ $(echo $installed_count) == 6 ]; then
    log "所有必要依赖已安装！" notice
else
    log "开始安装必要依赖..." notice
    if [ $OSVersion == "CentOS" ]; then
        if [ $USER == 'root' ]; then
            yum install -y libcurl libicu libkrb5-3 liblttng-ust0 libssl zlib1g
        else
            log "请使用 root 权限安装依赖！" warn
            log "切换到 root 用户并运行如下命令：" notice
            echo -e "yum install -y libcurl libicu libkrb5-3 liblttng-ust0 libssl zlib1g\n"
            log "依赖未安装完成！脚本已终止！" fatal
            exit 1
        fi
    else
        if [ $USER == 'root' ]; then
            auth=''
        else
            auth='sudo'
        fi
        if [ $(getconf WORD_BIT) = '32' ] && [ $(getconf LONG_BIT) = '64' ]; then
            $auth apt-get -y install libcurl libicu libkrb5-3 liblttng-ust0 libssl zlib1g
        else
            $auth apt-get -y install libcurl libicu libkrb5-3 liblttng-ust0 libssl zlib1g
        fi
    fi
    log "依赖安装完成！" success
fi

log 1 divider

if [ ! -f /usr/local/openssl/cert.pem ]; then
    log "没有在本地找到可用的SSL证书，之后运行ASF可能会报错：" WARN
    echo -e "\033[35mThe SSL connection could not be established, see inner exception.\033[0m"
    sslpath=$(openssl version -a | grep OPENSSLDIR | sed -r 's/.*"(.+)".*/\1/')
    cp $sslpath/cert.pem /usr/local/openssl/
    log "已尝试自动修复！" SUCCESS
fi
