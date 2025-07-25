##
# @brief Print text in green color
# @param $* Text to print in green
# @return 0 on success
# @example green_echo "Success message"
# @category tool
##
green_echo() {
	echo "\033[32m$*\033[0m"
}

# @brief Make directory and change to it
# @param $1 Directory path to create and enter
# @return 0 on success
# @example mc /tmp/newdir
# @category filesystem
mc() {
	mkdir -p -- "$1" && cd -P -- "$1"
}

# @brief Get all local network IP addresses (up to 10)
# @return 0 on success
# @example hostips
# @category network
hostips() {
	export HOST_IP="$(ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}' | head -n 10)"
	echo $HOST_IP
}

# @brief Get primary local network IP address
# @return 0 on success
# @example hostip
# @category network
hostip() {
	export HOST_IP="$(ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}' | head -n 1)"
	echo $HOST_IP
}

##
# @brief 获取当前的公网 IP 地址
# @return 公网 IPv4 地址
# @example get_wan_ip
# @category network
##
get_wan_ip() {
	curl -4 icanhazip.com
}

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

# 向后兼容别名
alias wanip="get_wan_ip"
alias setproxy="proxy_enable"
alias unsetproxy="proxy_disable"
alias printpx="show_proxy_status"
alias testconn="test_connectivity"

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


# @brief Set proxy from DNS TXT record with authentication support
# @param $1 Domain to query for proxy TXT record
# @param $2 DNS server (optional)
# @return 0 on success, 1 on error
# @example setpx_with_dns proxy.example.com 8.8.8.8
# @category network
setpx_with_dns(){
	# check if dig is installed
	if ! command -v dig &>/dev/null; then
		echo "Please install dig first"
		echo "Ubuntu: sudo apt install dnsutils"
		echo "MacOS: brew install dnsutils"
		echo "CentOS: sudo yum install bind-utils"
		echo "Arch: sudo pacman -S bind"
		echo "Alpine: sudo apk add bind-tools"
		return
	fi

	if [ -z "$1" ]; then
		echo "Please provide a url to get proxy"
		return 1
	fi
	
	# URL 安全验证
	local _url="$1"
	if [[ ! "$_url" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]$ ]]; then
		echo "Error: Invalid URL format. Only alphanumeric characters, dots, and hyphens allowed." >&2
		return 1
	fi

	# 如果提供了 DNS 服务器，则使用提供的 DNS 服务器
	if [ -n "$2" ]; then
		export DNS_SERVER=$2
	fi

	local _url=$1
	if [ -z "$DNS_SERVER" ]; then
		local _dns=$(dig +short TXT $_url | tr -d '"')
	else
		local _dns=$(dig +short TXT $_url @$DNS_SERVER | tr -d '"')
	fi
	if [ -z "$_dns" ]; then
		echo "Failed to get dns from $_url"
		return
	fi
	echo "Get Proxy: ${_dns}"
	
	# 两种: http://1.1.1.1:8080  socks5://1.1.1.1:1080 没有密码
	# 另外一种需要提供用户名密码 socks5://@1.1.1.1:1080 http://@1.1.1.1:8080 这种需要读取输入的账户密码

	# 判断是否需要输入密码
	if [[ $_dns == *"@"* ]]; then
		echo "Please input username and password for $_dns"
		read -p "Username: " _username
		
		# 安全的密码输入 - 隐藏输入内容
		echo -n "Password: "
		read -s _password
		echo  # 换行
		
		# 输入验证
		if [[ -z "$_username" || -z "$_password" ]]; then
			echo "Error: Username and password are required" >&2
			return 1
		fi
		
		# 提取协议和地址部分
		_protocol=$(echo $_dns | cut -d: -f1)
		_address=$(echo $_dns | sed 's/.*@//')
		
		# 验证协议
		if [[ ! "$_protocol" =~ ^(http|https|socks5)$ ]]; then
			echo "Error: Unsupported protocol '$_protocol'" >&2
			return 1
		fi
		
		proxy_enable "${_protocol}://${_username}:${_password}@${_address}"
		
		# 清理密码变量
		unset _password
	else
		# 如果不需要用户名和密码，直接使用 $_dns
		proxy_enable "$_dns"
	fi
	echo "Proxy set to $_dns"
	test_connectivity
}

# @brief Set proxy and test connectivity
# @param $1 Proxy URL
# @return 0 on success
# @example setpx_and_test http://127.0.0.1:7890
# @category network
setpx_and_test() {
	if [ -z "$1" ]; then
		echo "Please provide a proxy"
		return
	fi
	proxy_enable $1
	test_connectivity
}

# @brief Create hostips script in local bin directory
# @return 0 on success
# @example write_hostips
# @category network
write_hostips() {
	# use tee to write hostips to /usr/local/bin/hostips
	cat <<EOF >>$HOME/.local/bin/hostips
#!/usr/bin/bash
	
ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}' | head -n 1
EOF

	chmod +x $HOME/.local/bin/hostips

	sudo mv $HOME/.local/bin/hostips /usr/local/bin/
}
# pxio () {
# 	export https_proxy=http://10.10.43.3:1080
# 	export http_proxy=http://10.10.43.3:1080
# 	export all_proxy=socks5://10.10.43.3:1081
# 	echo "set proxy to 10.10.43.3:1080"
# }

# px () {
# 	export https_proxy=http://127.0.0.1:1080
# 	export http_proxy=http://127.0.0.1:1080
# 	export all_proxy=socks5://127.0.0.1:1081
# 	echo "set proxy to 127.0.0.1:1080"
# }

# nopx () {
# 	export https_proxy=
# 	export http_proxy=
# 	export all_proxy=
# 	echo "set proxy to nil"
# }

# auto set proxy
# setpx () {
# 	ping -c 1 -q 10.10.43.3 1> /dev/null; ping1=$?
# 	if [ $ping1 -eq 0 ]
# 	then
# 		pxio
# 	else
# 		px
# 	fi
# }

# @brief Check if current IP is in China with caching
# @return 0 if in China, 1 otherwise
# @example check_in_china
# @category network
check_in_china() {
	local _cache_file="$HOME/.cache/zsh_location"
	local _cache_ttl=86400  # 24小时缓存
	
	# 确保缓存目录存在
	mkdir -p "$(dirname "$_cache_file")"
	
	# 检查缓存是否存在且未过期
	if [[ -f "$_cache_file" ]]; then
		local _cache_time=$(stat -f %m "$_cache_file" 2>/dev/null || stat -c %Y "$_cache_file" 2>/dev/null)
		local _current_time=$(date +%s)
		
		# 确保时间变量不为空且为数字
		if [[ -n "$_cache_time" && -n "$_current_time" && "$_cache_time" =~ ^[0-9]+$ && "$_current_time" =~ ^[0-9]+$ && $((_current_time - _cache_time)) -lt $_cache_ttl ]]; then
			# 缓存有效，直接读取
			local _cached_country=$(cat "$_cache_file")
			[[ $_cached_country == "CN" ]] && return 0 || return 1
		fi
	fi
	
	# 缓存过期或不存在，进行网络检查
	# 安全的网络请求 - 使用HTTPS，严格SSL验证，设置User-Agent
	local _country=$(curl -s \
		--connect-timeout 3 \
		--max-time 5 \
		--fail \
		--location \
		--proto '=https' \
		--tlsv1.2 \
		--user-agent "zsh-config/1.0" \
		"https://ipinfo.io/country" 2>/dev/null)
	
	# 如果网络请求失败，使用默认值（非中国）
	if [[ -z "$_country" ]]; then
		_country="US"
	fi
	
	# 保存到缓存
	echo "$_country" > "$_cache_file"
	
	[[ $_country == "CN" ]] && return 0 || return 1
}

# @brief Copy current directory path or file path to clipboard
# @param $1 Optional file/directory name to append to current path
# @return 0 on success
# @example copypath myfile.txt
# @category filesystem
copypath() {
	if [ $# -gt 0 ]; then
		if [ "$(uname 2>/dev/null)" = "Linux" ]; then
			echo "$(pwd)/$@" | xclip -selection clipboard
		fi

		if [ "$(uname 2>/dev/null)" = "Darwin" ]; then
			echo "$(pwd)/$@" | pbcopy
		fi
	else
		if [ "$(uname 2>/dev/null)" = "Linux" ]; then
			pwd | xclip -selection clipboard
		fi

		if [ "$(uname 2>/dev/null)" = "Darwin" ]; then
			pwd | pbcopy
		fi
	fi
}

# @brief Copy file contents to clipboard
# @param $1 File path to copy
# @return 0 on success
# @example copyfile ~/.bashrc
# @category filesystem
copyfile() {
	if [ $# -gt 0 ]; then
		if [ "$(uname 2>/dev/null)" = "Linux" ]; then
			cat $1 | xclip -selection clipboard
		fi

		if [ "$(uname 2>/dev/null)" = "Darwin" ]; then
			cat $1 | pbcopy
		fi
	else
		yellow_echo "Please provide a file path"
	fi
}

# add clipboard data to .ssh/authorized_keys
# @brief Add SSH key from clipboard to authorized_keys
# @return 0 on success
# @example addsshkey
# @category security
addsshkey() {
	if [ "$(uname 2>/dev/null)" = "Linux" ]; then
		xclip -o >>~/.ssh/authorized_keys
	fi

	if [ "$(uname 2>/dev/null)" = "Darwin" ]; then
		pbpaste >>~/.ssh/authorized_keys
	fi
}

# @brief Display RGB color preview in terminal
# @param $1 Red value (0-255)
# @param $2 Green value (0-255)
# @param $3 Blue value (0-255)
# @return 0 on success
# @example show_rgb 255 0 0
# @category display
show_rgb() {
	printf "\e[38;2;%s;%s;%sm ■■■■■■■■■■■■ \e[0m\n" "${1}" "${2}" "${3}"
}

# @brief Wrapper for GetLatestRelease functions with retry logic and validation
# @param $1 Function name (GetLatestRelease or GetLatestReleaseProxy)
# @param $2 Repository name in format 'owner/repo'
# @return Latest version tag or exits with error after 3 failed attempts
# @example GetLatestReleaseWithRetry GetLatestReleaseProxy "microsoft/vscode"
# @category github
function GetLatestReleaseWithRetry() {
    local func_name="$1"
    local repo="$2"
    local max_retries=3
    local retry_count=0
    local version=""
    
    if [[ -z "$func_name" || -z "$repo" ]]; then
        echo "错误: 函数名和仓库名不能为空" >&2
        return 1
    fi
    
    while [[ $retry_count -lt $max_retries ]]; do
        retry_count=$((retry_count + 1))
        echo "尝试获取 $repo 的版本信息 (第 $retry_count 次)..." >&2
        
        # 调用指定的函数
        version=$($func_name "$repo" 2>/dev/null)
        
        # 验证版本号是否有效（非空且包含版本号格式）
        if [[ -n "$version" && "$version" =~ ^[0-9]+(\.[0-9]+)*(-.*)?$ ]]; then
            echo "成功获取版本: $version" >&2
            echo "$version"
            return 0
        fi
        
        echo "获取版本失败，版本信息为空或格式无效: '$version'" >&2
        
        if [[ $retry_count -lt $max_retries ]]; then
            echo "等待 2 秒后重试..." >&2
            sleep 2
        fi
    done
    
    echo "错误: 重试 $max_retries 次后仍无法获取 $repo 的版本信息" >&2
    return 1
}

# @brief Get latest release version from GitHub repository
# @param $1 Repository name in format 'owner/repo'
# @return Latest version tag
# @example GetLatestRelease microsoft/vscode
# @category github
function GetLatestRelease() {
	local repo="$1"
	local result=""
	
	if [[ -z "$repo" ]]; then
		echo "错误: 仓库名不能为空" >&2
		return 1
	fi
	
	# if GH_TOKEN is not empty, then
	# curl will use the token to get more requests
	# see https://developer.github.com/v3/#rate-limiting
	if [[ -n "$GHHH_TOKEN" ]]; then
		# echo "have token set"
		result=$(curl --connect-timeout 10 --max-time 30 --silent "https://ghapi.dqi.me/repos/$repo/releases/latest" --header "Authorization: Bearer ${GHHH_TOKEN}" | # Get latest release from GitHub api
			grep '"tag_name":' |                                                                                            # Get tag line
			sed -E 's/.*"v?([^"]+)".*/\1/')
	else
		result=$(curl --connect-timeout 10 --max-time 30 --silent "https://ghapi.dqi.me/repos/$repo/releases/latest" | # Get latest release from GitHub api
			grep '"tag_name":' |                                             # Get tag line
			sed -E 's/.*"v?([^"]+)".*/\1/')
	fi
	
	if [[ -n "$result" ]]; then
		echo "$result"
	else
		return 1
	fi
}

# @brief Get latest release with retry (defaults to proxy)
# @param $1 Repository name in format 'owner/repo'
# @return Latest version tag with retry logic
# @example GetLatestReleaseWithRetryProxy "microsoft/vscode"
# @category github
function GetLatestReleaseWithRetryProxy() {
    GetLatestReleaseWithRetry GetLatestReleaseProxy "$1"
}

# @brief Get latest release with retry (direct GitHub API)
# @param $1 Repository name in format 'owner/repo' 
# @return Latest version tag with retry logic
# @example GetLatestReleaseWithRetryDirect "microsoft/vscode"
# @category github
function GetLatestReleaseWithRetryDirect() {
    GetLatestReleaseWithRetry GetLatestRelease "$1"
}

# @brief Get latest release version via proxy for faster access
# @param $1 Repository name in format 'owner/repo'
# @return Latest version tag
# @example GetLatestReleaseProxy microsoft/vscode
# @category github
function GetLatestReleaseProxy() {
	local repo="$1"
	local result=""
	
	if [[ -z "$repo" ]]; then
		echo "错误: 仓库名不能为空" >&2
		return 1
	fi
	
	# if GH_TOKEN is not empty, then
	# curl will use the token to get more requests
	# see https://developer.github.com/v3/#rate-limiting
	if [[ -n "$GHHH_TOKEN" ]]; then
		# echo "have token set"
		result=$(curl --connect-timeout 10 --max-time 30 --silent "https://ghapi.dqi.me/repos/$repo/releases/latest" --header "Authorization: Bearer ${GHHH_TOKEN}" | # Get latest release from GitHub api
			grep '"tag_name":' |                                                                                                  # Get tag line
			sed -E 's/.*"v?([^"]+)".*/\1/')
	else
		result=$(curl --connect-timeout 10 --max-time 30 --silent "https://ghapi.dqi.me/repos/$repo/releases/latest" | # Get latest release from GitHub api
			grep '"tag_name":' |                                                   # Get tag line
			sed -E 's/.*"v?([^"]+)".*/\1/')
	fi
	
	if [[ -n "$result" ]]; then
		echo "$result"
	else
		return 1
	fi
}

# @brief Get latest release with retry (defaults to proxy)
# @param $1 Repository name in format 'owner/repo'
# @return Latest version tag with retry logic
# @example GetLatestReleaseWithRetryProxy "microsoft/vscode"
# @category github
function GetLatestReleaseWithRetryProxy() {
    GetLatestReleaseWithRetry GetLatestReleaseProxy "$1"
}

# @brief Get latest release with retry (direct GitHub API)
# @param $1 Repository name in format 'owner/repo' 
# @return Latest version tag with retry logic
# @example GetLatestReleaseWithRetryDirect "microsoft/vscode"
# @category github
function GetLatestReleaseWithRetryDirect() {
    GetLatestReleaseWithRetry GetLatestRelease "$1"
}

function get_wan_ip_china() {
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

function get_wan_ip() {
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