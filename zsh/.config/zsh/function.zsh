mc() {
	mkdir -p -- "$1" && cd -P -- "$1"
}

hostips() {
	export HOST_IP="$(ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}' | head -n 10)"
	echo $HOST_IP
}

hostip() {
	export HOST_IP="$(ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}' | head -n 1)"
	echo $HOST_IP
}

wanip() {
	curl -4 icanhazip.com
}

setproxy() {
	if [ -n "$1" ]; then
		_proxy=$1
	fi
	export https_proxy="${_proxy}"
	export http_proxy="${_proxy}"
	export ftp_proxy="${_proxy}"
	export all_proxy="${_proxy}"
	export no_proxy="localhost,192.168.0.0/16,10.0.0.0/8"
}


unsetproxy() {
	export https_proxy=""
	export http_proxy=""
	export ftp_proxy=""
	export all_proxy=""
	unset http_proxy
	unset https_proxy
	unset ftp_proxy
	unset all_proxy
}

printpx() {
	echo "----print current proxy-------"
	echo "http_proxy: ${http_proxy}"
	echo "https_proxy: ${https_proxy}"
	echo "ftp_proxy: ${ftp_proxy}"
	echo "all_proxy: ${all_proxy}"
}

testconn() {
    # 测试 Google 和 Gstatic 的连接
    echo "正在测试 Google 和 Gstatic 的连接..."
    if curl --connect-time 5 --speed-time 5 --speed-limit 1 https://www.gstatic.com/generate_204; then
        echo "成功连接到 www.gstatic.com"
    else
        echo "无法连接到 www.gstatic.com" >&2
    fi

    if curl --connect-time 5 --speed-time 5 --speed-limit 1 https://google.com &>/dev/null; then
        echo "成功连接到 google.com"
    else
        echo "无法连接到 google.com" >&2
    fi

    # 测试 Github 的连接
    echo "正在测试 Github 的连接..."
    if curl --connect-time 5 --speed-time 5 --speed-limit 1 https://api.github.com &>/dev/null; then
        echo "成功连接到 api.github.com"
    else
        echo "无法连接到 api.github.com" >&2
    fi

    # 测试 Cloudflare DNS 的连接
    echo "正在测试 Cloudflare DNS 的连接..."
    if curl --connect-time 5 --speed-time 5 --speed-limit 1 https://1.1.1.1 &>/dev/null; then
        echo "成功连接到 1.1.1.1 (Cloudflare DNS)"
    else
        echo "无法连接到 1.1.1.1 (Cloudflare DNS)" >&2
    fi

    # 测试额外的网站连接
    echo "正在测试额外的网站连接..."

    # 测试 Reddit
    if curl --connect-time 5 --speed-time 5 --speed-limit 1 https://www.reddit.com &>/dev/null; then
        echo "成功连接到 reddit.com"
    else
        echo "无法连接到 reddit.com" >&2
    fi

    # 测试 Twitter
    if curl --connect-time 5 --speed-time 5 --speed-limit 1 https://twitter.com &>/dev/null; then
        echo "成功连接到 twitter.com"
    else
        echo "无法连接到 twitter.com" >&2
    fi

    # 测试 Stack Overflow
    if curl --connect-time 5 --speed-time 5 --speed-limit 1 https://stackoverflow.com &>/dev/null; then
        echo "成功连接到 stackoverflow.com"
    else
        echo "无法连接到 stackoverflow.com" >&2
    fi

    echo "所有测试完成。"
}


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
		return
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
		read -p "Password: " _password
		# 提取协议和地址部分
		_protocol=$(echo $_dns | cut -d: -f1)
		_address=$(echo $_dns | sed 's/.*@//')
		setproxy "${_protocol}://${_username:-}:${_password:-}@${_address}"
	else
		# 如果不需要用户名和密码，直接使用 $_dns
		setproxy "$_dns"
	fi
	echo "Proxy set to $_dns"
	testconn
}

setpx_and_test() {
	if [ -z "$1" ]; then
		echo "Please provide a proxy"
		return
	fi
	setproxy $1
	testconn
}

write_hostips() {
	# use tee to write hostips to /usr/local/bin/hostips
	cat <<EOF >>$HOME/.local/bin/hostips
#/usr/bin/bash
	
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

check_in_china() {
	local _country=$(curl -s ipinfo.io/country)
	if [[ $_country == "CN" ]]; then
		# echo "You are in China"
		return 0
	else
		# echo "You are not in China $_country"
		return 1
	fi
}

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
addsshkey() {
	if [ "$(uname 2>/dev/null)" = "Linux" ]; then
		xclip -o >>~/.ssh/authorized_keys
	fi

	if [ "$(uname 2>/dev/null)" = "Darwin" ]; then
		pbpaste >>~/.ssh/authorized_keys
	fi
}

show_rgb() {
	printf "\e[38;2;%s;%s;%sm ■■■■■■■■■■■■ \e[0m\n" "${1}" "${2}" "${3}"
}

function GetLatestRelease() {
	# if GH_TOKEN is not empty, then
	# curl will use the token to get more requests
	# see https://developer.github.com/v3/#rate-limiting
	if [[ -n "$GHHH_TOKEN" ]]; then
		# echo "have token set"
		curl --silent "https://api.github.com/repos/$1/releases/latest" --header "Authorization: Bearer ${GHHH_TOKEN}" | # Get latest release from GitHub api
			grep '"tag_name":' |                                                                                            # Get tag line
			sed -E 's/.*"v*([^"]+)".*/\1/'
	else
		curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
			grep '"tag_name":' |                                             # Get tag line
			sed -E 's/.*"v*([^"]+)".*/\1/'
	fi
}

function GetLatestReleaseProxy() {
	# if GH_TOKEN is not empty, then
	# curl will use the token to get more requests
	# see https://developer.github.com/v3/#rate-limiting
	if [[ -n "$GHHH_TOKEN" ]]; then
		# echo "have token set"
		curl --silent "https://gh-api-sg.dengqi.org/repos/$1/releases/latest" --header "Authorization: Bearer ${GHHH_TOKEN}" | # Get latest release from GitHub api
			grep '"tag_name":' |                                                                                                  # Get tag line
			sed -E 's/.*"v*([^"]+)".*/\1/'
	else
		curl --silent "https://gh-api-sg.dengqi.org/repos/$1/releases/latest" | # Get latest release from GitHub api
			grep '"tag_name":' |                                                   # Get tag line
			sed -E 's/.*"v*([^"]+)".*/\1/'
	fi
}
