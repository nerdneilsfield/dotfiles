alias exp='explorer.exe'

function wsl_autostart_ssh(){
  sudo ln -sf /etc/init.d/ssh /etc/rc2.d/S18ssh
}

function wsl_gen_ssh_bat() {
 HOST_IP="$(ifconfig | grep "inet " | grep -Fv 127.0.0.1 | grep 172 | awk '{print $2}' | head -n 1)"
 HOST_PORT="$(cat /etc/ssh/sshd_config | grep ^Port | awk '{print $2}' | tail -n1)"
 CODENAME=$(lsb_release -c | awk '{print $2}')
 
 tee ~/setup_wsl_ssh.bat &>/dev/null << EOF
netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=2222 connectaddress=${HOST_IP} connectport=${HOST_PORT}
netsh advfirewall firewall add rule name=${HOST}_${CODENAME} dir=in action=allow protocol=TCP localport=2222
EOF
}

function wsl_get_host_ip(){
  # cat /etc/resolv.conf | grep -E "nameserver\W" | awk '{print $2}'
  ip route show default | awk '{print $3}'
}

# # color list: https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg
# zstyle :prompt:pure:path color 241
# zstyle :prompt:pure:git:branch color 031
# zstyle :prompt:pure:prompt:error color 160
# zstyle :prompt:pure:prompt:success color 031
