function Install-Wsl {
        sudo Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
        sudo Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
        sudo wsl --set-default-version 2
        sudo wsl --install
}

function Enable-SSH-Server {
        sudo Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
        sudo Start-Service sshd
        sudo Set-Service -Name sshd -StartupType 'Automatic'

        if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
            Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
            sudo New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
        } else {
            Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
        }
}

function Stop-SSH-Server {
        sudo Stop-Service sshd
}

function Change-SSH-Server-Shell {
        param (
                [string]$Shell="C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
        )
        sudo New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value $Shell -PropertyType String -Force
        sudo Restart-Service sshd
}

function List-Wsl {
        wsl -l -v
}

function Get-Wsl-IP {
        param (
                $Name
        )
        wsl -d $Name -I
}

function Open-Wsl-PortForward {
        param (
                $Name,
                $WindowsPort,
                $WslPort
        )

        $wsl_ipaddr = Get-Wsl-Ip $Name
        sudo netsh interface portproxy add v4tov4 listenport=$WindowsPort listenaddress=0.0.0.0 connectport=$WslPort connectaddress=$wsl_ipaddr
        sudo New-NetFirewallRule -DisplayName "${Name}_${WindowsPort}" -Direction Inbound -Protocol TCP –LocalPort ${WindowsPort} -Action Allow
}

function Show-Port-ForwardList {
        sudo netsh interface portproxy show all;


        sudo Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\PortProxy\v4tov4\tcp
}
