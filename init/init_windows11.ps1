
function InstallScoop {
        param (
        )
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser # Optional: Needed to run a remote script the first time
        Invoke-RestMethod get.scoop.sh | Invoke-Expression
        
        scoop install git 7zip
        scoop bucket add extras
        scoop bucket add nerd-fonts
        scoop bucket add nonportable
        scoop bucket add jetbrains
}


function InstallBasicApps() {
        scoop install git-lfs fzf bat bottom curl gh lazygit gitui ripgrep
        scoop install make sudo Powertoys geekuninstaller wget windirstat
        scoop install openhardwaremonitor aria2 everything
}

function InstallSholarApp() {
        scoop install zotero obisidian typora okular sumatrapdf sioyek marp logseq
}

function InstallDevelopment() {
        scoop install vscode sublime-text gcc llvm global ctags neovim vim neovim-qt rga
        scoop install neovide putty winscp winmerge puttie python go rustup sublime-merge fnm sourcetree
        scoop install cmake ninja xmake luajit NotepadNext openssl zig cloudcompare
}

function InstallUlitiyApp() {
        scoop install snipaste screentogif obs-studio rufus etcher rclone wireshark lessmsi barrier
        scoop install Czkawka diskgenius nirlauncher wezterm vncviewer
}

function InstallMedia() {
        scoop install potplayer mpv foobar2000 foobar2000-encoders yt-dlp
}

function InstallVcredist() {
        scoop install vcredist2010 vcredist2012 vcredist2013 vcredist2015 vcredist2017 vcredist2019
}

function InstallSocial() {
        scoop install telegram
}

function InstallGame() {
        scoop install steam
}

function InstallFont() {
        scoop install SourceCodePro-NF-Mono RobotoMono-NF-Mono JetBrainsMono-NF-Mono Iosevka-NF-Mono Inconsolata-NF-Mono IBMPlexMono-NF-Mono FiraCode-NF-Mono
}

function EnableWsl() {
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
        Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
}

function InstallWsl() {
        wsl --install
}