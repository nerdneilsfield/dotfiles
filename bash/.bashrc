#!/bin/bash
# ============================================================================
# 功能完善的 Bash 配置文件
# 无需任何外部插件，开箱即用
# ============================================================================

# ----------------------------------------------------------------------------
# 基础设置
# ----------------------------------------------------------------------------

# 如果不是交互式 shell，直接返回
[[ $- != *i* ]] && return

# 设置默认编辑器
export EDITOR='vim'
export VISUAL='vim'

# 语言和编码设置
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# 增加历史记录大小
export HISTSIZE=10000
export HISTFILESIZE=20000

# 历史记录优化
shopt -s histappend                 # 追加而不是覆盖历史
shopt -s cmdhist                    # 多行命令保存为一条
export HISTCONTROL=ignoreboth       # 忽略重复和空格开头的命令
export HISTIGNORE="ls:ll:cd:pwd:bg:fg:history:clear:exit"
export HISTTIMEFORMAT="%F %T "      # 添加时间戳

# Shell 选项
shopt -s checkwinsize              # 窗口大小改变时更新 LINES 和 COLUMNS
shopt -s cdspell                   # 自动纠正 cd 命令的小错误
shopt -s dirspell                  # 目录名自动纠错
shopt -s nocaseglob               # 文件名匹配时忽略大小写
shopt -s autocd 2>/dev/null       # 输入目录名直接进入（Bash 4.0+）

# 设置终端标题
case "$TERM" in
    xterm*|rxvt*|screen*|tmux*)
        PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
        ;;
esac

# ----------------------------------------------------------------------------
# 颜色定义
# ----------------------------------------------------------------------------

# PS1 专用颜色（带 \[ \] 标记）
PS1_RESET='\[\033[0m\]'
PS1_RED='\[\033[0;31m\]'
PS1_GREEN='\[\033[0;32m\]'
PS1_YELLOW='\[\033[0;33m\]'
PS1_BLUE='\[\033[0;34m\]'
PS1_MAGENTA='\[\033[0;35m\]'
PS1_CYAN='\[\033[0;36m\]'
PS1_WHITE='\[\033[0;37m\]'

PS1_BOLD_RED='\[\033[1;31m\]'
PS1_BOLD_GREEN='\[\033[1;32m\]'
PS1_BOLD_YELLOW='\[\033[1;33m\]'
PS1_BOLD_BLUE='\[\033[1;34m\]'
PS1_BOLD_MAGENTA='\[\033[1;35m\]'
PS1_BOLD_CYAN='\[\033[1;36m\]'
PS1_BOLD_WHITE='\[\033[1;37m\]'

# 普通输出用颜色（不带 \[ \] 标记）
C_RESET='\033[0m'
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_BLUE='\033[0;34m'
C_MAGENTA='\033[0;35m'
C_CYAN='\033[0;36m'
C_WHITE='\033[0;37m'

C_BOLD_RED='\033[1;31m'
C_BOLD_GREEN='\033[1;32m'
C_BOLD_YELLOW='\033[1;33m'
C_BOLD_BLUE='\033[1;34m'
C_BOLD_MAGENTA='\033[1;35m'
C_BOLD_CYAN='\033[1;36m'
C_BOLD_WHITE='\033[1;37m'

# ----------------------------------------------------------------------------
# Git 状态函数
# ----------------------------------------------------------------------------

git_prompt() {
    local git_branch=""
    local git_status=""
    local git_dirty=""

    # 检查是否在 Git 仓库中
    if git rev-parse --git-dir > /dev/null 2>&1; then
        # 获取分支名
        git_branch=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

        # 检查工作区状态
        if [[ -n $(git status -s 2>/dev/null) ]]; then
            git_dirty="*"
        fi

        # 检查是否有未推送的提交
        local ahead=$(git rev-list --count @{u}.. 2>/dev/null)
        local behind=$(git rev-list --count ..@{u} 2>/dev/null)

        if [[ -n $ahead && $ahead -gt 0 ]]; then
            git_status+="↑${ahead}"
        fi

        if [[ -n $behind && $behind -gt 0 ]]; then
            git_status+="↓${behind}"
        fi

        # 构建输出（使用 PS1 颜色变量）
        echo "${PS1_MAGENTA} (${git_branch}${git_dirty}${git_status})${PS1_RESET}"
    fi
}

# ----------------------------------------------------------------------------
# Python 虚拟环境提示
# ----------------------------------------------------------------------------

python_venv_prompt() {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        local venv_name=$(basename "$VIRTUAL_ENV")
        echo -e "${COLOR_YELLOW}(${venv_name})${COLOR_RESET} "
    fi
}

# ----------------------------------------------------------------------------
# 上一个命令的退出状态
# ----------------------------------------------------------------------------

exit_status_prompt() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        echo -e "${COLOR_BOLD_RED}[$exit_code]${COLOR_RESET} "
    fi
}

# ----------------------------------------------------------------------------
# 美化的命令提示符
# ----------------------------------------------------------------------------

# 保存退出状态
__prompt_command() {
    local exit_code=$?

    # 历史记录追加
    history -a

    # 构建提示符
    PS1=""

    # 上一个命令退出状态
    if [[ $exit_code -ne 0 ]]; then
        PS1+="${PS1_BOLD_RED}[$exit_code]${PS1_RESET} "
    fi

    # Python 虚拟环境
    if [[ -n "$VIRTUAL_ENV" ]]; then
        PS1+="${PS1_YELLOW}($(basename "$VIRTUAL_ENV"))${PS1_RESET} "
    fi

    # 用户名和主机名
    if [[ $EUID -eq 0 ]]; then
        PS1+="${PS1_BOLD_RED}\u${PS1_RESET}"
    else
        PS1+="${PS1_BOLD_GREEN}\u${PS1_RESET}"
    fi

    PS1+="${PS1_WHITE}@${PS1_RESET}"
    PS1+="${PS1_BOLD_CYAN}\h${PS1_RESET}"

    # 当前目录
    PS1+=" ${PS1_BOLD_BLUE}\w${PS1_RESET}"

    # Git 状态
    PS1+="$(git_prompt)"

    # 提示符
    if [[ $EUID -eq 0 ]]; then
        PS1+="\n${PS1_BOLD_RED}#${PS1_RESET} "
    else
        PS1+="\n${PS1_BOLD_GREEN}\$${PS1_RESET} "
    fi
}

PROMPT_COMMAND=__prompt_command

# ----------------------------------------------------------------------------
# 实用别名 - 基础命令增强
# ----------------------------------------------------------------------------

# ls 系列
alias ls='ls --color=auto'
alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'
alias lt='ls -alFht'          # 按时间排序
alias lS='ls -alFhS'          # 按大小排序
alias l.='ls -d .* --color=auto'  # 只显示隐藏文件

# cd 系列
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'

# grep 系列
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# 安全操作
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ln='ln -i'

# 其他常用命令
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias mkdir='mkdir -pv'
alias wget='wget -c'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%Y-%m-%d %H:%M:%S"'
alias ports='netstat -tulanp'

# 进程管理
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias myps='ps aux | grep $USER'

# 系统信息
alias meminfo='free -h -l -t'
alias cpuinfo='lscpu'
alias diskusage='df -h | grep -v "tmpfs\|loop"'

# 网络相关
alias myip='curl -s ifconfig.me'
alias localip='hostname -I'
alias openports='ss -tulanp'

# 快速编辑配置文件
alias bashrc='${EDITOR} ~/.bashrc'
alias vimrc='${EDITOR} ~/.vimrc'
alias tmuxrc='${EDITOR} ~/.tmux.conf'
alias reload='source ~/.bashrc && echo "Bashrc reloaded!"'

# ----------------------------------------------------------------------------
# Git 别名
# ----------------------------------------------------------------------------

alias gs='git status'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gp='git push'
alias gpl='git pull'
alias gd='git diff'
alias gdc='git diff --cached'
alias gl='git log --oneline --graph --decorate --all'
alias glog='git log --oneline --decorate --graph'
alias gb='git branch'
alias gba='git branch -a'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gm='git merge'
alias gf='git fetch'
alias gr='git remote -v'
alias gst='git stash'
alias gstp='git stash pop'
alias gstl='git stash list'

# ----------------------------------------------------------------------------
# Docker 别名
# ----------------------------------------------------------------------------

alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs -f'
alias dstop='docker stop $(docker ps -q)'
alias drm='docker rm $(docker ps -aq)'
alias drmi='docker rmi $(docker images -q)'
alias dprune='docker system prune -af'

# ----------------------------------------------------------------------------
# 实用函数
# ----------------------------------------------------------------------------

# 创建目录并进入
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# 提取各种压缩文件
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *.tar.xz)    tar xf "$1"      ;;
            *)           echo "'$1' 无法被提取" ;;
        esac
    else
        echo "'$1' 不是一个有效的文件"
    fi
}

# 查找文件
ff() {
    find . -type f -iname "*$1*"
}

# 查找目录
fd() {
    find . -type d -iname "*$1*"
}

# 在文件中查找内容
findin() {
    if [ $# -lt 1 ]; then
        echo "Usage: findin <pattern> [path]"
        return 1
    fi
    local pattern="$1"
    local path="${2:-.}"
    grep -rnw "$path" -e "$pattern" --color=auto
}

# 快速备份文件
backup() {
    if [ $# -eq 0 ]; then
        echo "Usage: backup <file>"
        return 1
    fi
    local filename="$1"
    local backup_name="${filename}.$(date +%Y%m%d_%H%M%S).bak"
    cp "$filename" "$backup_name"
    echo "已备份到: $backup_name"
}

# 计算目录大小
dirsize() {
    du -sh "${1:-.}" | cut -f1
}

# 显示最大的文件/目录
largest() {
    du -ah "${1:-.}" | sort -rh | head -n "${2:-10}"
}

# 端口占用检查
portcheck() {
    if [ $# -eq 0 ]; then
        echo "Usage: portcheck <port>"
        return 1
    fi
    lsof -i :"$1" || echo "端口 $1 未被占用"
}

# 显示进程树
pstree_custom() {
    ps -ef --forest | grep -v grep | grep "${1:-.}"
}

# 快速启动 HTTP 服务器
serve() {
    local port="${1:-8000}"
    echo "启动 HTTP 服务器在端口 $port ..."
    if command -v python3 &> /dev/null; then
        python3 -m http.server "$port"
    elif command -v python &> /dev/null; then
        python -m SimpleHTTPServer "$port"
    else
        echo "错误: 未找到 Python"
        return 1
    fi
}

# 快速计算器
calc() {
    echo "$*" | bc -l
}

# 天气查询
weather() {
    local location="${1:-}"
    curl -s "wttr.in/${location}?lang=zh"
}

# 显示系统信息
sysinfo() {
    echo -e "\n${C_BOLD_CYAN}系统信息${C_RESET}"
    echo "================================"
    echo "主机名: $(hostname)"
    echo "操作系统: $(uname -o)"
    echo "内核版本: $(uname -r)"
    echo "架构: $(uname -m)"
    echo "运行时间: $(uptime -p 2>/dev/null || uptime)"
    echo "当前用户: $(whoami)"
    echo "当前时间: $(date)"
    echo ""
    echo -e "${C_BOLD_CYAN}CPU 信息${C_RESET}"
    echo "--------------------------------"
    lscpu | grep -E "型号名称|CPU|核心" | head -3
    echo ""
    echo -e "${C_BOLD_CYAN}内存使用${C_RESET}"
    echo "--------------------------------"
    free -h
    echo ""
    echo -e "${C_BOLD_CYAN}磁盘使用${C_RESET}"
    echo "--------------------------------"
    df -h | grep -v "tmpfs\|loop" | head -5
    echo ""
}

# Git 快捷操作
gacp() {
    if [ $# -eq 0 ]; then
        echo "Usage: gacp <commit_message>"
        return 1
    fi
    git add .
    git commit -m "$*"
    git push
}

# 创建 Git 忽略文件
gitignore() {
    local type="${1:-Python}"
    curl -s "https://www.gitignore.io/api/$type"
}

# 目录跳转历史
declare -a DIR_STACK
DIR_STACK_MAX=10

pushd_custom() {
    if [ $# -eq 0 ]; then
        echo "Usage: pushd_custom <directory>"
        return 1
    fi

    # 添加到历史
    DIR_STACK=("$(pwd)" "${DIR_STACK[@]}")

    # 保持最大长度
    if [ ${#DIR_STACK[@]} -gt $DIR_STACK_MAX ]; then
        DIR_STACK=("${DIR_STACK[@]:0:$DIR_STACK_MAX}")
    fi

    cd "$1" || return 1
}

popd_custom() {
    if [ ${#DIR_STACK[@]} -eq 0 ]; then
        echo "目录栈为空"
        return 1
    fi

    cd "${DIR_STACK[0]}" || return 1
    DIR_STACK=("${DIR_STACK[@]:1}")
}

dirs_custom() {
    echo "当前目录: $(pwd)"
    if [ ${#DIR_STACK[@]} -gt 0 ]; then
        echo "目录历史:"
        for i in "${!DIR_STACK[@]}"; do
            echo "  $i: ${DIR_STACK[$i]}"
        done
    else
        echo "目录栈为空"
    fi
}

# 别名简化
alias pd='pushd_custom'
alias po='popd_custom'
alias ds='dirs_custom'

# ----------------------------------------------------------------------------
# 命令补全增强
# ----------------------------------------------------------------------------

# 启用可编程补全
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
elif [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi

# Git 补全（如果存在）
if [ -f /usr/share/bash-completion/completions/git ]; then
    . /usr/share/bash-completion/completions/git
fi

# Docker 补全（如果存在）
if [ -f /usr/share/bash-completion/completions/docker ]; then
    . /usr/share/bash-completion/completions/docker
fi

# SSH 主机名补全
if [ -f ~/.ssh/config ]; then
    complete -W "$(awk '/^Host / {print $2}' ~/.ssh/config | grep -v '\*')" ssh scp sftp
fi

# ----------------------------------------------------------------------------
# 智能命令纠错
# ----------------------------------------------------------------------------

command_not_found_handle() {
    local cmd="$1"

    # 常见错误纠正
    case "$cmd" in
        claer|clea|lear)
            clear
            ;;
        grpe|gre)
            echo "你是不是想输入: grep"
            ;;
        mroe|moer)
            echo "你是不是想输入: more"
            ;;
        les)
            echo "你是不是想输入: less"
            ;;
        *)
            # 尝试使用 command-not-found 工具
            if [ -x /usr/lib/command-not-found ]; then
                /usr/lib/command-not-found -- "$cmd"
                return $?
            elif [ -x /usr/share/command-not-found/command-not-found ]; then
                /usr/share/command-not-found/command-not-found -- "$cmd"
                return $?
            else
                echo "bash: $cmd: 未找到命令"
                return 127
            fi
            ;;
    esac
}

# ----------------------------------------------------------------------------
# 性能监控快捷命令
# ----------------------------------------------------------------------------

# CPU 使用率 Top 10
cputop() {
    ps aux --sort=-%cpu | head -n 11
}

# 内存使用率 Top 10
memtop() {
    ps aux --sort=-%mem | head -n 11
}

# 磁盘 I/O 监控
iotop_simple() {
    iostat -x 1 5 2>/dev/null || echo "需要安装 sysstat: sudo apt install sysstat"
}

# 网络连接统计
netstat_summary() {
    echo "活动连接统计:"
    ss -s 2>/dev/null || netstat -s 2>/dev/null
}

# ----------------------------------------------------------------------------
# 开发环境相关
# ----------------------------------------------------------------------------

# Python 虚拟环境快捷创建
mkvenv() {
    local venv_name="${1:-.venv}"
    python3 -m venv "$venv_name"
    echo "虚拟环境 '$venv_name' 已创建"
    echo "使用 'source $venv_name/bin/activate' 来激活"
}

# 激活 Python 虚拟环境
venv() {
    local venv_path="${1:-.venv}"
    if [ -f "$venv_path/bin/activate" ]; then
        source "$venv_path/bin/activate"
        echo "已激活虚拟环境: $venv_path"
    else
        echo "错误: 未找到虚拟环境 '$venv_path'"
        return 1
    fi
}

# 代码行数统计
cloc_simple() {
    local dir="${1:-.}"
    echo "代码统计 (不包括空行和注释):"
    find "$dir" -type f \( -name "*.py" -o -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.hpp" -o -name "*.java" -o -name "*.js" \) \
        -exec wc -l {} + | sort -rn | head -20
}

# 查找大文件
findbig() {
    local size="${1:-100M}"
    local path="${2:-.}"
    find "$path" -type f -size +"$size" -exec ls -lh {} \; | awk '{ print $9 ": " $5 }' | sort -k 2 -hr
}

# 批量重命名
batch_rename() {
    if [ $# -lt 2 ]; then
        echo "Usage: batch_rename <old_pattern> <new_pattern>"
        return 1
    fi
    local old_pattern="$1"
    local new_pattern="$2"

    for file in *"$old_pattern"*; do
        if [ -f "$file" ]; then
            local new_name="${file//$old_pattern/$new_pattern}"
            mv -i "$file" "$new_name"
            echo "$file -> $new_name"
        fi
    done
}

# ----------------------------------------------------------------------------
# 加载本地自定义配置
# ----------------------------------------------------------------------------

if [ -f ~/.bashrc.local ]; then
    source ~/.bashrc.local
fi

# ----------------------------------------------------------------------------
# 欢迎信息
# ----------------------------------------------------------------------------

if [ -n "$PS1" ]; then
    echo -e "${C_BOLD_CYAN}"
    echo "================================"
    echo "  欢迎使用增强版 Bash Shell"
    echo "================================"
    echo -e "${C_RESET}"
    echo "系统: $(uname -s) $(uname -r)"
    echo "用户: $(whoami)@$(hostname)"
    echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    echo "实用命令:"
    echo "  sysinfo      - 显示系统信息"
    echo "  weather      - 查询天气"
    echo "  extract      - 智能解压"
    echo "  serve        - 启动HTTP服务器"
    echo "  reload       - 重新加载配置"
    echo ""
fi

# ----------------------------------------------------------------------------
# PATH 增强（如果需要）
# ----------------------------------------------------------------------------

# 添加用户本地 bin 目录
if [ -d "$HOME/bin" ] && [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    export PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# ----------------------------------------------------------------------------
# 结束
# ----------------------------------------------------------------------------

