get_OSVersion() {
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
}
get_OSBits() {
    if [[ $(getconf LONG_BIT) == "64" ]]; then
        OSBits="64"
    else
        OSBits="32"
    fi
}
get_OSVersion
get_OSBits
echo -e "当前操作系统为 ${OSVersion} - ${OSBits}bit"
