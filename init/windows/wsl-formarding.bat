@echo off
for /f "tokens=*" %%a in ('wsl hostname -I') do set wslIP=%%a

echo WSL IP: %wslIP%

netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=2222 connectaddress=%wslIP% connectport=16922
netsh advfirewall firewall add rule name=GameStation_focal dir=in action=allow protocol=TCP localport=16922