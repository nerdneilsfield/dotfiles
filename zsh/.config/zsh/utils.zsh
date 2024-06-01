export COLOR_RED="\033[31m"
export COLOR_GREEN="\033[32m"
export COLOR_YELLOW="\033[33m"
export COLOR_WHITE="\033[37m"
export COLOR_BLACK="\033[30m"
export COLOR_BLUE="\033[34m"
export COLOR_MAGENTA="\033[35m"  # 紫色
export COLOR_CYAN="\033[36m"     # 青色
export COLOR_RESET="\033[0m"

red_echo() {
  echo -e "${COLOR_RED}${1}${COLOR_RESET}"
}

blue_echo() {
  echo -e "${COLOR_BLUE}${1}${COLOR_RESET}"
}

green_echo() {
  echo -e "${COLOR_GREEN}${1}${COLOR_RESET}"
}

yellow_echo() {
  echo -e "${COLOR_YELLOW}${1}${COLOR_RESET}"
}

cyan_echo() {
  echo -e "${COLOR_CYAN}${1}${COLOR_RESET}"
}

magenta_echo() {
  echo -e "${COLOR_MAGENTA}${1}${COLOR_RESET}"
}

pkill-fzf(){
  # 获取当前用户的进程列表，并使用 fzf 选择要杀掉的进程
  selected=$(ps -u $(whoami) -o pid,comm,etime,pcpu,pmem,args --sort=-pcpu | fzf --multi --preview 'echo {}' --preview-window down:3:wrap)

  # 如果没有选择任何进程，则退出
  if [ -z "$selected" ]; then
    echo "No process selected."
    exit 0
  fi

  # 提取选中的进程 ID
  pids=$(echo "$selected" | awk '{print $1}')

  # 杀掉选中的进程
  for pid in $pids; do
    kill -9 $pid
    echo "Killed process $pid"
  done
}

pkill-fzf-sudo(){
  # 获取当前用户的进程列表，并使用 fzf 选择要杀掉的进程
  selected=$(ps -u $(whoami) -o pid,comm,etime,pcpu,pmem,args --sort=-pcpu | fzf --multi --preview 'echo {}' --preview-window down:3:wrap)

  # 如果没有选择任何进程，则退出
  if [ -z "$selected" ]; then
    echo "No process selected."
    exit 0
  fi

  # 提取选中的进程 ID
  pids=$(echo "$selected" | awk '{print $1}')

  # 杀掉选中的进程
  for pid in $pids; do
    sudo kill -9 $pid
    echo "Killed process $pid"
  done
}

function fzf-view-log() {
  local log=$(find /var/log -type f | fzf)
  if [[ -n "$log" ]]; then
    less "$log"
  fi
}

function sed-replace() {
  local inplace=false
  local file=""
  local original=""
  local replacement=""

  # 解析参数
  while [[ $# -gt 0 ]]; do
    case $1 in
      --inplace)
        inplace=true
        shift
        ;;
      *)
        if [[ -z "$file" ]]; then
          file=$1
        elif [[ -z "$original" ]]; then
          original=$1
        elif [[ -z "$replacement" ]]; then
          replacement=$1
        fi
        shift
        ;;
    esac
  done

  # 检查参数是否完整
  if [[ -z "$file" || -z "$original" || -z "$replacement" ]]; then
    echo "Usage: sed-replace [--inplace] <file> <original> <replacement>"
    return 1
  fi

  # 转义原始字符串和目标字符串中的特殊字符
  local escaped_original=$(printf '%s\n' "$original" | sed 's/[]\/$*.^|[]/\\&/g')
  local escaped_replacement=$(printf '%s\n' "$replacement" | sed 's/[&/\]/\\&/g')

  # 构建 sed 命令
  local sed_command="s/$escaped_original/$escaped_replacement/g"

  if $inplace; then
    sed -i "$sed_command" "$file"
  else
    sed "$sed_command" "$file"
  fi
}

# 示例用法
# sed-replace --inplace "文件名" "原始正则表达式" "目标字符串"
# sed-replace "文件名" "原始正则表达式" "目标字符串"
