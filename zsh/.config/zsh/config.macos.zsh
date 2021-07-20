
# homebrew
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles


alias ipk='/usr/local/bin/brew'

alias ipki='/usr/local/bin/brew install'
alias ipkic='/usr/local/bin/brew install --cask'
alias ipkr="/usr/local/bin/brew uninstall"
alias ipkrc='/usr/local/bin/brew install --cask'


alias apk="/opt/brew/bin/brew"

# gcloud
# export CLOUDSDK_PYTHON=python2
# # updates PATH for the Google Cloud SDK.
# if [ -f '/Users/taiga/code/app/gcloud/path.zsh.inc' ]; 
# then 
# 	. '/Users/taiga/code/app/gcloud/path.zsh.inc'; 
# fi
# # enables shell command completion for gcloud.
# if [ -f '/Users/taiga/code/app/gcloud/completion.zsh.inc' ]; 
# then 
# 	. '/Users/taiga/code/app/gcloud/completion.zsh.inc'; 
# fi

alias subl='/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl'
alias cot='/Applications/CotEditor.app/Contents/MacOS/CotEditor'
alias ipaddr="ifconfig | grep -E '[10|192]\.\d{1,3}\.\d{1,3}\.\d{1,3}' | gawk '{print $2}'"

### !!! Iterm
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


export PYTHON_PATH=/usr/local/bin/python3
export MAC_SDK="/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.15.sdk"
export CPATH="${MAC_SDK}/usr/include"