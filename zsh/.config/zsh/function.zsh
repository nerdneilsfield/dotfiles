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

# @brief Remove dangling completion links and stale compinit dump
# @return 0 on success, 1 if cleanup fails
zsh_fix_completions() {
	emulate -L zsh
	setopt local_options null_glob

	local dir entry dumpfile removed=0
	for dir in $fpath; do
		[[ -d "$dir" ]] || continue
		for entry in "$dir"/_*(N); do
			[[ -L "$entry" && ! -e "$entry" ]] || continue
			command rm -f -- "$entry" || return 1
			(( removed++ ))
		done
	done

	if (( removed )); then
		dumpfile="${ZSH_COMPDUMP:-${ZDOTDIR:-$HOME}/.zcompdump}"
		if [[ -e "$dumpfile" || -L "$dumpfile" ]]; then
			command rm -f -- "$dumpfile" || return 1
		fi
		print -r -- "zsh_fix_completions: removed $removed dangling completion link(s)"
	fi
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
# get_wan_ip() {
# 	curl -4 icanhazip.com
# }

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
# @brief 测试网络连接性（并行 + 多格式输出）
# @description 并发探测一组常用站点，输出 HTTP 状态码与耗时。
#              默认列表：gstatic / google / api.github / 1.1.1.1 / reddit / twitter / stackoverflow。
#              可通过位置参数自定义目标，或经 stdin 传入（每行一个）。
# @option --quiet 仅输出失败项
# @option --json  输出 JSON 数组
# @option --tsv   输出 TSV：url<TAB>status<TAB>http_code<TAB>time_ms
# @option --dry-run 列出将要测试的目标，不执行
# @option -j N    并发数（默认 6）
# @option -n N    每个 URL 探测轮数（默认 1；>1 时报告均值/最小/最大）
# @option --timeout SEC 单站超时（默认 10）
# @return 0 全部成功；1 任一失败
# @example test_connectivity
# @example test_connectivity --json
# @example test_connectivity --tsv --quiet
# @example test_connectivity https://github.com https://example.com
# @example printf "https://a.com\nhttps://b.com\n" | test_connectivity -
# @category network
##
test_connectivity() {
    # 局部抑制 job control 噪音（互动 shell 默认 monitor/notify）
    emulate -L zsh
    setopt local_options no_monitor no_notify

    local concurrency=6 timeout=10 rounds=5
    local -a positional=()
    # 解析自有选项 + 透传给 __tools_parse_args
    local -a passthrough=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -j)        concurrency="$2"; shift 2 ;;
            --timeout) timeout="$2"; shift 2 ;;
            -n)        rounds="$2"; shift 2 ;;
            -j*)       concurrency="${1#-j}"; shift ;;
            -n*)       rounds="${1#-n}"; shift ;;
            --timeout=*) timeout="${1#--timeout=}"; shift ;;
            *) passthrough+=("$1"); shift ;;
        esac
    done
    [[ ! "$rounds" =~ ^[0-9]+$ || "$rounds" -lt 1 ]] && rounds=1

    # 复用 tools.zsh I/O 框架（若未载入则提供退化路径）
    if (( ! ${+functions[__tools_parse_or_help]} )); then
        # tools.zsh 未载入，使用极简退化逻辑
        local url ok=1
        local -a urls=("${passthrough[@]}")
        [[ ${#urls[@]} -eq 0 ]] && urls=(
            https://www.gstatic.com/generate_204
            https://google.com
            https://api.github.com
            https://1.1.1.1
            https://www.reddit.com
            https://twitter.com
            https://stackoverflow.com
            https://chatgpt.com
            https://claude.ai
            https://gemini.google.com
            https://www.perplexity.ai
            https://huggingface.co
            https://openai.com
            https://www.anthropic.com
            https://x.com
            https://www.youtube.com
        )
        for url in "${urls[@]}"; do
            if curl --connect-timeout 5 --max-time "$timeout" -sS -o /dev/null "$url" 2>/dev/null; then
                printf '✅ %s\n' "$url"
            else
                printf '❌ %s\n' "$url" >&2
                ok=0
            fi
        done
        return $(( 1 - ok ))
    fi

    __tools_parse_or_help "Usage: test_connectivity [-q|--quiet] [--json|--tsv] [--dry-run] [-j N] [-n N] [--timeout SEC] [url...|-]" "${passthrough[@]}" \
        || { local _rc=$?; [[ $_rc -eq 2 ]] && return 0; return $_rc; }

    local _json=$ZSH_TOOLS_JSON _tsv=$ZSH_TOOLS_TSV _quiet=$ZSH_TOOLS_QUIET _dry=$ZSH_TOOLS_DRY_RUN
    local -a rest=("${passthrough[@]:$((ZSH_TOOLS_OPT_INDEX-1))}")

    __tools_read_stdin_or_args "${rest[@]}"

    local -a default_urls=(
        https://www.gstatic.com/generate_204
        https://google.com
        https://api.github.com
        https://1.1.1.1
        https://www.reddit.com
        https://twitter.com
        https://stackoverflow.com
        https://chatgpt.com
        https://claude.ai
        https://gemini.google.com
        https://www.perplexity.ai
        https://huggingface.co
        https://openai.com
        https://www.anthropic.com
        https://x.com
        https://www.youtube.com
    )
    local -a urls
    if [[ ${#ZSH_TOOLS_INPUT_LINES[@]} -gt 0 ]]; then
        urls=("${ZSH_TOOLS_INPUT_LINES[@]}")
    else
        urls=("${default_urls[@]}")
    fi

    if [[ $_dry -eq 1 ]]; then
        local u
        for u in "${urls[@]}"; do __tools_output "$u"; done
        return 0
    fi

    if ! command -v curl >/dev/null 2>&1; then
        __tools_error "curl not found"; return 1
    fi

    # 并行执行 curl，每个结果输出 'url|http_code|time_total_seconds|exit'
    local tmpdir
    tmpdir=$(mktemp -d 2>/dev/null) || tmpdir="/tmp/testconn.$$"
    mkdir -p "$tmpdir"

    local probe_one
    probe_one() {
        local u="$1" t="$2" outfile="$3"
        local body
        body=$(curl --connect-timeout 5 --max-time "$t" -sS -o /dev/null \
                    -w '%{http_code}|%{time_total}' "$u" 2>/dev/null)
        local rc=$?
        printf '%s|%s|%s\n' "$u" "$body" "$rc" > "$outfile"
    }

    # 通知运行模式
    if [[ $_quiet -eq 0 && $_json -eq 0 && $_tsv -eq 0 ]]; then
        if [[ $rounds -gt 1 ]]; then
            __tools_info "🔁 跑 $rounds 轮 × ${#urls[@]} 站 = $((rounds * ${#urls[@]})) 次探测（并发 $concurrency, 超时 ${timeout}s）"
        fi
    fi

    local total_jobs=0
    local r u
    local -a pids=()
    local pids_running=0
    for ((r=1; r<=rounds; r++)); do
        for u in "${urls[@]}"; do
            ((total_jobs++))
            probe_one "$u" "$timeout" "$tmpdir/$total_jobs" &
            pids+=($!)
            ((pids_running++))
            if [[ $pids_running -ge $concurrency ]]; then
                wait "${pids[@]}"
                pids=()
                pids_running=0
            fi
        done
    done
    [[ ${#pids[@]} -gt 0 ]] && wait "${pids[@]}"

    # 收集所有原始记录
    local -a raw=()
    local j
    for ((j=1; j<=total_jobs; j++)); do
        [[ -r "$tmpdir/$j" ]] && raw+=("$(<"$tmpdir/$j")")
    done
    rm -rf "$tmpdir"

    # 按 URL 聚合
    typeset -A agg_ok agg_fail agg_sum agg_min agg_max agg_last_code
    local entry url http_code time_s rc time_ms
    for entry in "${raw[@]}"; do
        url="${entry%%|*}"; entry="${entry#*|}"
        http_code="${entry%%|*}"; entry="${entry#*|}"
        time_s="${entry%%|*}"; entry="${entry#*|}"
        rc="$entry"

        time_ms="0"
        if [[ -n "$time_s" ]]; then
            time_ms=$(awk -v t="$time_s" 'BEGIN{printf "%d", t*1000}')
            [[ -z "$time_ms" ]] && time_ms="0"
        fi

        if [[ "$rc" == "0" && -n "$http_code" && "$http_code" =~ ^[23] ]]; then
            agg_ok[$url]=$(( ${agg_ok[$url]:-0} + 1 ))
            agg_sum[$url]=$(( ${agg_sum[$url]:-0} + time_ms ))
            local cur_min=${agg_min[$url]:-}
            local cur_max=${agg_max[$url]:-}
            if [[ -z "$cur_min" || $time_ms -lt $cur_min ]]; then agg_min[$url]=$time_ms; fi
            if [[ -z "$cur_max" || $time_ms -gt $cur_max ]]; then agg_max[$url]=$time_ms; fi
        else
            agg_fail[$url]=$(( ${agg_fail[$url]:-0} + 1 ))
            [[ -z "$http_code" ]] && http_code="000"
        fi
        agg_last_code[$url]="$http_code"
    done

    # 生成最终 parsed 行：url|st|http_code|avg_ms|min_ms|max_ms|ok|fail
    local total_ok=0 total_fail=0
    local -a parsed=()
    local ok_cnt fail_cnt avg_ms min_ms max_ms st
    for u in "${urls[@]}"; do
        ok_cnt=${agg_ok[$u]:-0}
        fail_cnt=${agg_fail[$u]:-0}
        if [[ $ok_cnt -gt 0 ]]; then
            avg_ms=$(( agg_sum[$u] / ok_cnt ))
            min_ms=${agg_min[$u]}
            max_ms=${agg_max[$u]}
            if [[ $fail_cnt -eq 0 ]]; then
                st="ok"
                ((total_ok++))
            else
                st="partial"
                ((total_fail++))
            fi
        else
            avg_ms=0; min_ms=0; max_ms=0
            st="fail"
            ((total_fail++))
        fi
        parsed+=("$u|$st|${agg_last_code[$u]:-000}|$avg_ms|$min_ms|$max_ms|$ok_cnt|$fail_cnt")
    done

    if [[ $_json -eq 1 ]]; then
        __tools_output "["
        local -a json_lines=() esc_url
        local p
        for p in "${parsed[@]}"; do
            IFS='|' read -r url st http_code avg_ms min_ms max_ms ok_cnt fail_cnt <<< "$p"
            esc_url=$(__tools_json_escape "$url")
            json_lines+=("  {\"url\":\"$esc_url\",\"status\":\"$st\",\"http_code\":\"$http_code\",\"rounds\":$rounds,\"ok\":$ok_cnt,\"fail\":$fail_cnt,\"avg_ms\":$avg_ms,\"min_ms\":$min_ms,\"max_ms\":$max_ms}")
        done
        local k n=${#json_lines[@]}
        for ((k=1; k<=n; k++)); do
            if [[ $k -lt $n ]]; then
                __tools_output "${json_lines[$k]},"
            else
                __tools_output "${json_lines[$k]}"
            fi
        done
        __tools_output "]"
    elif [[ $_tsv -eq 1 ]]; then
        [[ $_quiet -eq 0 ]] && __tools_output $'url\tstatus\thttp_code\tok\tfail\tavg_ms\tmin_ms\tmax_ms'
        local p
        for p in "${parsed[@]}"; do
            IFS='|' read -r url st http_code avg_ms min_ms max_ms ok_cnt fail_cnt <<< "$p"
            printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$url" "$st" "$http_code" "$ok_cnt" "$fail_cnt" "$avg_ms" "$min_ms" "$max_ms"
        done
    else
        ZSH_TOOLS_QUIET=$_quiet
        local fmt_input=""
        if [[ $rounds -gt 1 ]]; then
            [[ $_quiet -eq 0 ]] && fmt_input+=$'STATUS\tHTTP\tOK/N\tAVG(ms)\tMIN(ms)\tMAX(ms)\tURL\n'
        else
            [[ $_quiet -eq 0 ]] && fmt_input+=$'STATUS\tHTTP\tTIME(ms)\tURL\n'
        fi
        local mark p
        for p in "${parsed[@]}"; do
            IFS='|' read -r url st http_code avg_ms min_ms max_ms ok_cnt fail_cnt <<< "$p"
            case "$st" in
                ok)      mark="✅" ;;
                partial) mark="⚠️ " ;;
                *)       mark="❌" ;;
            esac
            if [[ $_quiet -eq 1 && "$st" == "ok" ]]; then
                continue
            fi
            if [[ $rounds -gt 1 ]]; then
                fmt_input+="$mark"$'\t'"$http_code"$'\t'"$ok_cnt/$rounds"$'\t'"$avg_ms"$'\t'"$min_ms"$'\t'"$max_ms"$'\t'"$url"$'\n'
            else
                fmt_input+="$mark"$'\t'"$http_code"$'\t'"$avg_ms"$'\t'"$url"$'\n'
            fi
        done
        if command -v column >/dev/null 2>&1; then
            printf '%s' "$fmt_input" | column -t -s $'\t'
        else
            printf '%s' "$fmt_input"
        fi
        if [[ $_quiet -eq 0 ]]; then
            __tools_info ""
            __tools_info "📊 $total_ok 成功 / $total_fail 失败 (含部分失败) / 共 ${#urls[@]}（并发 $concurrency, 超时 ${timeout}s, 轮数 $rounds）"
        fi
    fi

    [[ $total_fail -gt 0 ]] && return 1
    return 0
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


# 基础版本 - 测试单个端口
check_port() {
    local host=$1
    local port=$2
    local timeout=${3:-3}  # 默认超时3秒

    if [[ -z "$host" || -z "$port" ]]; then
        echo "用法: check_port <主机> <端口> [超时秒数]"
        echo "示例: check_port google.com 80"
        return 1
    fi

    if nc -z -w$timeout "$host" "$port" 2>/dev/null; then
        echo "✓ $host:$port 端口开放"
        return 0
    else
        echo "✗ $host:$port 端口关闭或不可达"
        return 1
    fi
}

# 增强版本 - 测试多个端口
check_ports() {
    local host=$1
    local timeout=${2:-3}
    shift 2
    local ports=("$@")

    if [[ -z "$host" || ${#ports[@]} -eq 0 ]]; then
        echo "用法: check_ports <主机> [超时秒数] <端口1> <端口2> ..."
        echo "示例: check_ports google.com 3 80 443 22"
        return 1
    fi

    echo "测试 $host 的端口连接性..."
    echo "----------------------------------------"

    local open_count=0
    local total_count=${#ports[@]}

    for port in "${ports[@]}"; do
        if nc -z -w$timeout "$host" "$port" 2>/dev/null; then
            echo "✓ 端口 $port: 开放"
            ((open_count++))
        else
            echo "✗ 端口 $port: 关闭"
        fi
    done

    echo "----------------------------------------"
    echo "结果: $open_count/$total_count 个端口开放"
}

# 端口范围测试版本
check_port_range() {
    local host=$1
    local start_port=$2
    local end_port=$3
    local timeout=${4:-2}

    if [[ -z "$host" || -z "$start_port" || -z "$end_port" ]]; then
        echo "用法: check_port_range <主机> <起始端口> <结束端口> [超时秒数]"
        echo "示例: check_port_range 192.168.1.1 20 25"
        return 1
    fi

    echo "扫描 $host 端口范围 $start_port-$end_port..."
    echo "----------------------------------------"

    local open_ports=()

    for ((port=start_port; port<=end_port; port++)); do
        if nc -z -w$timeout "$host" "$port" 2>/dev/null; then
            echo "✓ 端口 $port: 开放"
            open_ports+=($port)
        fi
    done

    echo "----------------------------------------"
    if [[ ${#open_ports[@]} -gt 0 ]]; then
        echo "开放的端口: ${open_ports[*]}"
    else
        echo "没有发现开放的端口"
    fi
}

# 快速常用端口检测
quick_check() {
    local host=$1
    local timeout=${2:-3}

    if [[ -z "$host" ]]; then
        echo "用法: quick_check <主机> [超时秒数]"
        echo "示例: quick_check google.com"
        return 1
    fi

    # 常用端口列表
    local common_ports=(21 22 23 25 53 80 110 143 443 993 995)

    echo "快速检测 $host 的常用端口..."
    check_ports "$host" "$timeout" "${common_ports[@]}"
}

# 带颜色输出的版本
check_port_color() {
    local host=$1
    local port=$2
    local timeout=${3:-3}

    # 颜色定义
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local NC='\033[0m' # No Color

    if [[ -z "$host" || -z "$port" ]]; then
        echo -e "${YELLOW}用法: check_port_color <主机> <端口> [超时秒数]${NC}"
        echo -e "${YELLOW}示例: check_port_color google.com 80${NC}"
        return 1
    fi

    echo -e "${YELLOW}测试 $host:$port ...${NC}"

    if nc -z -w$timeout "$host" "$port" 2>/dev/null; then
        echo -e "${GREEN}✓ $host:$port 端口开放${NC}"
        return 0
    else
        echo -e "${RED}✗ $host:$port 端口关闭或不可达${NC}"
        return 1
    fi
}
