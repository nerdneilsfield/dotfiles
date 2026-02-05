#/usr/bin/env bash
#


export _proxy="socks5://127.0.0.1:7890"

##
# @brief 启用代理设置
# @description 设置 HTTP、HTTPS、FTP 和所有协议的代理，并配置本地网络免代理
# @param $1 代理地址 (格式: http://host:port 或 socks5://host:port)
# @return 0 设置成功
# @example proxy_enable http://127.0.0.1:7890
# @category network
##
proxy_enable() {
	if [ -n "$1" ]; then
		_proxy=$1
	fi
	export https_proxy="${_proxy}"
	export http_proxy="${_proxy}"
	export ftp_proxy="${_proxy}"
	export all_proxy="${_proxy}"
	export no_proxy="localhost,192.168.0.0/16,10.0.0.0/8"
}

##
# @brief 禁用代理设置
# @description 清空所有代理环境变量
# @return 0 总是成功
# @example proxy_disable
# @category network
##
proxy_disable() {
	export https_proxy=""
	export http_proxy=""
	export ftp_proxy=""
	export all_proxy=""
	unset http_proxy
	unset https_proxy
	unset ftp_proxy
	unset all_proxy
}

##
# @brief 显示当前代理状态
# @description 显示所有代理相关环境变量的当前值
# @return 0 总是成功
# @example show_proxy_status
# @category network
##
show_proxy_status() {
	echo "----print current proxy-------"
	echo "http_proxy: ${http_proxy}"
	echo "https_proxy: ${https_proxy}"
	echo "ftp_proxy: ${ftp_proxy}"
	echo "all_proxy: ${all_proxy}"
}

##
# @brief 测试网络连接性
# @description 测试连接到 Google、Github、Cloudflare 等常用网站的网络状况
# @return 0 测试完成
# @example test_connectivity
# @category network
##
test_connectivity() {
    # 测试 Google 和 Gstatic 的连接
    echo "正在测试 Google 和 Gstatic 的连接..."
    if curl --connect-timeout 5 --max-time 10 -s https://www.gstatic.com/generate_204; then
        echo "成功连接到 www.gstatic.com"
    else
        echo "无法连接到 www.gstatic.com" >&2
    fi

    if curl --connect-timeout 5 --max-time 10 -s https://google.com &>/dev/null; then
        echo "成功连接到 google.com"
    else
        echo "无法连接到 google.com" >&2
    fi

    # 测试 Github 的连接
    echo "正在测试 Github 的连接..."
    if curl --connect-timeout 5 --max-time 10 -s https://api.github.com &>/dev/null; then
        echo "成功连接到 api.github.com"
    else
        echo "无法连接到 api.github.com" >&2
    fi

    # 测试 Cloudflare DNS 的连接
    echo "正在测试 Cloudflare DNS 的连接..."
    if curl --connect-timeout 5 --max-time 10 -s https://1.1.1.1 &>/dev/null; then
        echo "成功连接到 1.1.1.1 (Cloudflare DNS)"
    else
        echo "无法连接到 1.1.1.1 (Cloudflare DNS)" >&2
    fi

    # 测试额外的网站连接
    echo "正在测试额外的网站连接..."

    # 测试 Reddit
    if curl --connect-timeout 5 --max-time 10 -s https://www.reddit.com &>/dev/null; then
        echo "成功连接到 reddit.com"
    else
        echo "无法连接到 reddit.com" >&2
    fi

    # 测试 Twitter
    if curl --connect-timeout 5 --max-time 10 -s https://twitter.com &>/dev/null; then
        echo "成功连接到 twitter.com"
    else
        echo "无法连接到 twitter.com" >&2
    fi

    # 测试 Stack Overflow
    if curl --connect-timeout 5 --max-time 10 -s https://stackoverflow.com &>/dev/null; then
        echo "成功连接到 stackoverflow.com"
    else
        echo "无法连接到 stackoverflow.com" >&2
    fi

    echo "所有测试完成。"
}


get_wan_ip_china() {
	echo "=====cip.cc======"
	echo ""
	curl -s cip.cc
	echo ""
	# echo "=====ip.cn======"
	# echo ""
	# curl -s ip.cn
	# echo ""
	echo "=====ip.sb======"
	echo ""
	curl -s ip.sb
	echo ""
	# echo "=====myip.ipip.net======"
	# echo ""
	# curl -s myip.ipip.net
	# echo ""
	echo "=====ipx.sh======="
	echo ""
	curl -s ipx.sh
	echo ""
	echo "=====members.3322.org======"
	echo ""
	curl -s members.3322.org/dyndns/getip
	echo ""
	echo "=====pubyun.com/dyndns/getip======"
	echo ""
	curl -s pubyun.com/dyndns/getip
}

get_wan_ip() {
	echo "=====ifconfig.me======"
	curl -s ifconfig.me
	echo ""
	echo "=====icanhazip.com======"
	curl -s icanhazip.com
	echo ""
	echo "=====api.ipify.org======"
	curl -s api.ipify.org
	echo ""
	echo "=====ipinfo.io/ip======"
	curl -s ipinfo.io/ip
	echo ""
	echo "=====ipecho.net/plain======"
	curl -s ipecho.net/plain
	echo ""
	echo "=====ip.nf======"
	curl -s ip.nf
	echo ""
	echo "=====ident.me======"
	curl -s ident.me
}


alias setpx="proxy_enable"
alias unsetpx="proxy_disable"
alias setproxy="proxy_enable"
alias unsetproxy="proxy_disable"
alias printpx="show_proxy_status"
alias testconn="test_connectivity"
