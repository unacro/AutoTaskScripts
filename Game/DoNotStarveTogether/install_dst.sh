#!/usr/bin/env bash
#=================================================
#   Author: Cyanashi
#   Version: 1.0.0
#   Updated: 2020-04-07
#   Required: CentOS/Debian/Ubuntu
#   Description: 饥荒服务端管理脚本
#   Link: https://github.com/Cyanashi/AutoTaskScripts
#=================================================
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
Workspace="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ScriptVersion="1.0.0"
LastUpdated="2020-04-07"

SteamcmdPath="$HOME/steamcmd"
ServerPath="$HOME/dontstarvetogether_dedicated_server"
ConfigPath="$HOME/.klei/DoNotStarveTogether"
ClusterName="MyDediServer"
master_start="$HOME/dst_server/start_master.sh"
caves_start="$HOME/dst_server/start_caves.sh"

ip_regex="\b(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[1-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[1-9])\b"

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

function del_file() {
    if [ -e "$1" ]; then
        rm "$1"
    fi
}

function fail() {
    echo Error: "$@" >&2
    exit 1
}

log 1 divider

log "饥荒服务端管理脚本 v${ScriptVersion} 最后更新时间 ${LastUpdated}" notice

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
if [ $(yum list installed | grep glibc.i686 | wc -l) == 1 ]; then
    let installed_count+=1
    log "依赖包 glibc.i686 已安装。"
fi
if [ $(yum list installed | grep libstdc++.i686 | wc -l) == 1 ]; then
    let installed_count+=1
    log "依赖包 libstdc++.i686 已安装。"
fi
if [ $(yum list installed | grep libcurl.i686 | wc -l) == 1 ]; then
    let installed_count+=1
    log "依赖包 libcurl.i686 已安装。"
fi
if [ $(echo $installed_count) == 3 ]; then
    log "必要依赖已安装！" notice
else
    log "开始安装必要依赖..." notice
    if [ $OSVersion == "CentOS" ]; then
        if [ $USER == 'root' ]; then
            yum install -y glibc.i686 libstdc++.i686 libcurl.i686
        else
            log "请使用 root 权限安装依赖！" warn
            log "切换到 root 用户并运行如下命令：" notice
            echo -e "yum install -y glibc.i686 libstdc++.i686 libcurl.i686\n"
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
            $auth apt-get -y install libstdc++6:i386 libgcc1:i386 libcurl4-gnutls-dev:i386
        else
            $auth apt-get -y install libstdc++6 libgcc1 libcurl4-gnutls-dev
        fi
    fi
    log "依赖安装完成！" success
fi

log 1 divider

if [ -f $SteamcmdPath/steamcmd.sh ]; then
    log "SteamCMD 已安装！" notice
else
    log "开始安装 SteamCMD ..." notice
    mkdir "$SteamcmdPath"
    cd "$SteamcmdPath"
    if [ ! -f steamcmd_linux.tar.gz ]; then
        wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
        tar -xvzf steamcmd_linux.tar.gz
    fi
    if [ $? -eq 0 ]; then
        log "SteamCMD 安装完成！" success
    fi
fi

log 1 divider

if [ $OSVersion == 'CentOS' ]; then
    IFS=' ' uname_info=($(uname -a))
    kernel_version="${uname_info[2]}"
    if [[ $kernel_version =~ ^3.10.0-957.27.2* ]]; then
        log "当前 CentOS 的内核版本过低（ $kernel_version ）！\n将导致无法匿名登录 SteamCMD 并下载饥荒联机版服务端！" fatal
        log "请切换到 root 权限使用以下命令更新内核：" notice
        echo -e "yum update kernel\n"
        log "然后使用 reboot 重启本机后继续！" notice
        log "脚本已终止！" fatal
        exit 1
    fi
fi
if [ -f $ServerPath/bin/dontstarve_dedicated_server_nullrenderer ]; then
    log "饥荒联机版服务端 已安装！" notice
else
    log "开始安装 饥荒联机版服务端 ..." notice
    cd "$SteamcmdPath" || fail "没有找到 SteamCMD 文件夹 $SteamcmdPath ！"
    ./steamcmd.sh +force_install_dir "$ServerPath" +login anonymous +app_update 343050 validate +quit
    if [ $? -eq 0 ]; then
        log "饥荒联机版服务端 安装完成！" success
    fi
fi

log 1 divider

if [ -f $ServerPath/bin/lib32/libcurl-gnutls.so.4 ]; then
    lib_link=$(ls -ld $ServerPath/bin/lib32/libcurl-gnutls.so.4 | awk '{print $NF}')
    if [ $lib_link != "/usr/lib/libcurl.so.4" ]; then
        log "检测到依赖库文件 libcurl-gnutls.so.4 的链接指向错误！" warn
        ln -s /usr/lib/libcurl.so.4 $ServerPath/bin/lib32/libcurl-gnutls.so.4
        if [ $? -eq 0 ]; then
            log "自动修复成功！已链接到 /usr/lib/libcurl.so.4 ！" success
        fi
        log 1 divider
    fi
else
    ln -s /usr/lib/libcurl.so.4 $ServerPath/bin/lib32/libcurl-gnutls.so.4
    log "检测到依赖库文件 libcurl-gnutls.so.4 的链接指向错误！已自动修复成功！" notice
    log 1 divider
fi

log "请选择如何安装服务器：（输入 1 / 2 / 3 并回车）" notice
echo "1. 将地面和洞穴服务器（ Master and Caves ）都安装到此($(hostname))"
echo "2. 仅在此($(hostname))安装地面服务器（ only Master ）"
echo "3. 仅在此($(hostname))安装洞穴服务器（ only Caves ）"
read install_mode
case $install_mode in
1) log "选择将地面和洞穴服务器（ Master and Caves ）都安装到此($(hostname))" notice ;;
2) log "选择仅在此($(hostname))安装地面服务器（ only Master ）" notice ;;
3) log "选择仅在此($(hostname))安装洞穴服务器（ only Caves ）" notice ;;
*)
    log "输入非法！脚本已终止！" fatal
    exit 1
    ;;
esac

log 1 divider

log "开始安装服务器..." notice

if [ $install_mode != 3 ]; then
    mkdir -p $ConfigPath/$ClusterName/Master
fi
if [ $install_mode != 2 ]; then
    mkdir -p $ConfigPath/$ClusterName/Caves
fi
mkdir -p $HOME/dst_server

log "请输入你的 cluster_token ："
read cluster_token
cat >$ConfigPath/$ClusterName/cluster_token.txt <<EOF
$cluster_token
EOF
log "请输入服务器名："
read server_name
log "请输入服务器描述："
read server_desc
log "请输入服务器密码："
read server_passwd
bind_ip='0.0.0.0'
if [ $install_mode != 3 ]; then
    log "查询本机当前公网IP..."
    vps_ip=$(curl --connect-timeout 5 ifconfig.me)
    if [ $(echo $vps_ip | egrep $ip_regex | wc -l) == 1 ]; then
        log "查询成功！master_ip 已设置为 $vps_ip ！" success
        master_ip=$vps_ip
    else
        log "查询公网IP失败！请手动输入本服务器公网IP：" warn
        read input_ip
        if [ $(echo $input_ip | egrep $ip_regex | wc -l) == 1 ]; then
            log "master_ip 已设置为 $input_ip ！" success
            master_ip=$input_ip
        else
            log "输入格式非法！master_ip 已暂时使用本地(127.0.0.1)！\n请在安装完成后再次打开此脚本或直接手动编辑 $ConfigPath/$ClusterName/cluster.ini 修改！" warn
            master_ip='127.0.0.1'
        fi
    fi
else
    log "请输入主服务器（ Master ）所在服务器（即地上服务器）的公网IP：" warn
    read input_ip
    if [ $(echo $input_ip | egrep $ip_regex | wc -l) == 1 ]; then
        log "master_ip 已设置为 $input_ip ！" success
        master_ip=$input_ip
    else
        log "输入格式非法！master_ip 已暂时使用注释！\n" error
        log "请务必在安装完成后编辑 $ConfigPath/$ClusterName/cluster.ini 修改！" warn
        master_ip='这里填地面服务器的公网IP，本机是洞穴服务器'
    fi
fi
log "请输入服务器端口（ master_port ）："
read input_port
if [ $(($input_port + 0)) -gt 0 -a $(($input_port + 0)) -lt 65535 ]; then
    log "master_port 已设置为 $input_port ！" success
    master_port=$input_port
else
    log "输入格式非法！master_port 已默认为11000！\n需要使用别的端口请自行修改！" warn
    master_port=11000
fi

cat >$ConfigPath/$ClusterName/cluster.ini <<EOF
[GAMEPLAY]
game_mode = endless
max_players = 6
pvp = false
pause_when_empty = true

[NETWORK]
cluster_name = $server_name
cluster_description = $server_desc
cluster_password = $server_passwd
cluster_intention = cooperative
cluster_language = zh

[MISC]
console_enabled = true

[SHARD]
shard_enabled = true
bind_ip = $bind_ip
master_ip = $master_ip
master_port = $master_port
cluster_key = whatever
EOF
log "已生成服务器集群配置（ cluster.ini ）"

if [ $install_mode != 3 ]; then
    cat >$master_start <<EOF
#!/bin/bash
cd $ServerPath/bin
./dontstarve_dedicated_server_nullrenderer -console -cluster "$ClusterName" -shard Master
EOF
    log "已生成地面服务器启动脚本（ $master_start ）"
    chmod +x $master_start
    cat >$ConfigPath/$ClusterName/Master/server.ini <<EOF
[NETWORK]
server_port = 11001

[SHARD]
is_master = true

[STEAM]
master_server_port = 11002
authentication_port = 11003
EOF
    log "已生成地面服务器配置（ Master/server.ini ）"
fi

if [ $install_mode != 2 ]; then
    cat >$caves_start <<EOF
#!/bin/bash
cd $ServerPath/bin
./dontstarve_dedicated_server_nullrenderer -console -cluster "$ClusterName" -shard Caves
EOF
    log "已生成洞穴服务器启动脚本（ $caves_start ）"
    chmod +x $caves_start
    # if [ $install_mode == 1 ]; then
    #    master_port="$(($master_port + 1))"
    # fi
    cat >$ConfigPath/$ClusterName/Caves/server.ini <<EOF
[NETWORK]
server_port = 12001

[SHARD]
is_master = false
name = Caves

[STEAM]
master_server_port = 12002
authentication_port = 12003
EOF
    log "已生成洞穴服务器配置（ Caves/server.ini ）"
    cat >$ConfigPath/$ClusterName/Caves/worldgenoverride.lua <<EOF
return {
    override_enabled = true,
    preset = "DST_CAVE",
}
EOF
fi

log "饥荒联机版服务端配置完成！" success

log 1 divider

log "检查对应端口..." notice

if [ $USER == 'root' ]; then
    if [ $install_mode != 3 ]; then
        firewall-cmd --zone=public --add-port=$master_port/udp --permanent
        firewall-cmd --zone=public --add-port=11001/udp --permanent
        firewall-cmd --zone=public --add-port=11002/udp --permanent
        firewall-cmd --zone=public --add-port=11003/udp --permanent
    fi
    if [ $install_mode != 2 ]; then
        firewall-cmd --zone=public --add-port=12001/udp --permanent
        firewall-cmd --zone=public --add-port=12002/udp --permanent
        firewall-cmd --zone=public --add-port=12003/udp --permanent
    fi
else
    log "请使用 root 权限运行以下命令确认对应端口已经打开：" notice
    if [ $install_mode != 3 ]; then
        echo -e "firewall-cmd --zone=public --\033[36mquery\033[0m-port=\033[36m$master_port\033[0m/udp"
        echo -e "firewall-cmd --zone=public --\033[36mquery\033[0m-port=\033[36m11001\033[0m/udp"
        echo -e "firewall-cmd --zone=public --\033[36mquery\033[0m-port=\033[36m11002\033[0m/udp"
        echo -e "firewall-cmd --zone=public --\033[36mquery\033[0m-port=\033[36m11003\033[0m/udp"
    fi
    if [ $install_mode != 2 ]; then
        echo -e "firewall-cmd --zone=public --\033[36mquery\033[0m-port=\033[36m12001\033[0m/udp"
        echo -e "firewall-cmd --zone=public --\033[36mquery\033[0m-port=\033[36m12002\033[0m/udp"
        echo -e "firewall-cmd --zone=public --\033[36mquery\033[0m-port=\033[36m12003\033[0m/udp"
    fi
    echo -e "\n"
    log "若防火墙未放通对应端口，请使用 root 权限运行以下命令：" notice
    echo -e "firewall-cmd --zone=public --\033[36madd\033[0m-port=\033[36m对应端口\033[0m/udp --permanent"
    echo -e "firewall-cmd --reload\n"
fi
log "除了本服务器上的防火墙要放通端口之外；\nIDC供应商处（阿里云 / 腾讯云 etc）的 安全组 也要注意放通对应 入方向 UDP 端口。" warn

log 1 divider

log "生成快捷方式（位于 $HOME/dst_server ）..." notice

cat >$ConfigPath/$ClusterName/adminlist.txt <<EOF
EOF
ln -s $ConfigPath/$ClusterName $HOME/dst_server/config
ln -s $ConfigPath/$ClusterName/cluster.ini $HOME/dst_server/cluster.ini
ln -s $ConfigPath/$ClusterName/cluster_token.txt $HOME/dst_server/cluster_token.txt
ln -s $ConfigPath/$ClusterName/adminlist.txt $HOME/dst_server/adminlist.txt
ln -s $ServerPath/mods/dedicated_server_mods_setup.lua $HOME/dst_server/mods.lua
if [ $install_mode != 3 ]; then
    ln -s $ConfigPath/$ClusterName/Master/server.ini $HOME/dst_server/master.ini
fi
if [ $install_mode != 2 ]; then
    ln -s $ConfigPath/$ClusterName/Caves/server.ini $HOME/dst_server/caves.ini
fi

log "全部任务执行完成！脚本已退出！" success

log 1 divider
