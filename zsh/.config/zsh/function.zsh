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
	export https_proxy="${_proxy}"
	export http_proxy="${_proxy}"
	export ftp_proxy="${_proxy}"
	export all_proxy="${_proxy}"
}

unsetproxy() {
	export https_proxy=""
	export http_proxy=""
	export ftp_proxy=""
	export all_proxy=""
}

printpx() {
	echo "----print current proxy-------"
	echo "http_proxy: ${http_proxy}"
	echo "https_proxy: ${https_proxy}"
	echo "ftp_proxy: ${ftp_proxy}"
	echo "all_proxy: ${all_proxy}"
}

testconn() {
	curl --connect-time 5 --speed-time 5 --speed-limit 1 https://www.gstatic.com/generate_204
	curl --connect-time 5 --speed-time 5 --speed-limit 1 https://google.co
}

setpx_and_test(){
	setpxup $1; setpx; testconn;
}


write_hostips(){
  # use tee to write hostips to /usr/local/bin/hostips
cat << EOF >> $HOME/.local/bin/hostips
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

show_rgb() {
	printf "\e[38;2;%s;%s;%sm ■■■■■■■■■■■■ \e[0m\n" "${1}" "${2}" "${3}"
}
