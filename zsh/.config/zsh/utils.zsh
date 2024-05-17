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



