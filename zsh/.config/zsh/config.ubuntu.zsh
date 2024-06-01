say_hi(){
        echo "Im from ubuntu or deb"
}

get_ubuntu_version() {
        if hash lsb_release 2>/dev/null; then
                lsb_release -c | awk '{print $2}'
        else
                sudo apt install -y lsb-release
                lsb_release -c | awk '{print $2}'
        fi
}

install_llvm(){
        wget -O /tmp/llvm.sh https://apt.llvm.org/llvm.sh
        chmod +x /tmp/llvm.sh
        sudo /tmp/llvm.sh $1
}

install_llvm_tuna(){
        wget -O /tmp/llvm.sh https://mirrors.tuna.tsinghua.edu.cn/llvm-apt/llvm.sh
        chmod +x /tmp/llvm.sh
        sudo /tmp/llvm.sh  all -m https://mirrors.tuna.tsinghua.edu.cn/llvm-apt
}


add_gcc_ppa() {
   sudo add-apt-repository ppa:ubuntu-toolchain-r/test
   sudo apt update
}

install_gcc() {
  sudo apt install -y "gcc-${1}" 
}

add_graph_drivers() {
  sudo add-apt-repository ppa:graphics-drivers/ppa
}

replace_ppa_source() {
  for file in /etc/apt/sources.list.d/*; do
    if grep -q "^[^#]*ppa.launchpad.net" "$file"; then
      echo "找到 ppa 在 $file"
      # 生成一个随机的临时文件名
      temp_file=$(mktemp /tmp/temp_sources.list.XXXXXX)
      sudo awk '
        /^deb / && !/^#.*ppa.launchpad.net/ && /ppa.launchpad.net/ {
          print "#" $0; 
          sub("http://ppa.launchpad.net/", "https://launchpad.proxy.ustclug.org/", $0); 
          print; 
          next
        }
        {print}
      ' "$file" > "$temp_file" && sudo mv "$temp_file" "$file"
    fi
    if grep -q "^[^#]*ppa.launchpadcontent.net" "$file"; then
      echo "找到 ppa 在 $file"
      # 生成一个随机的临时文件名
      temp_file=$(mktemp /tmp/temp_sources.list.XXXXXX)
      sudo awk '
        /^deb / && !/^#.*ppa.launchpadcontent.net/ && /ppa.launchpadcontent.net/ {
          print "#" $0; 
          sub("https://ppa.launchpadcontent.net/", "https://launchpad.proxy.ustclug.org/", $0); 
          print; 
          next
        }
        {print}
      ' "$file" > "$temp_file" && sudo mv "$temp_file" "$file"
    fi
  done
}

clean_duplicate_ppa() {
  # 创建一个临时文件来存储所有 PPA 定义
  temp_file=$(mktemp /tmp/temp_ppa_list.XXXXXX)
  echo "创建临时文件: $temp_file"

  # 遍历 /etc/apt/sources.list.d/ 目录中的所有文件
  for file in /etc/apt/sources.list.d/*; do
    # 读取文件内容并将 PPA 定义添加到临时文件中
    awk '/^deb / {print FILENAME ":" $0}' "$file" >> "$temp_file"
  done

  echo "所有 PPA 定义:"
  cat "$temp_file"

  # 查找重复的 PPA 定义
  duplicates=$(cut -d: -f2- "$temp_file" | sort | uniq -d)

  echo "找到的重复 PPA 定义:"
  echo "$duplicates"

  # 如果没有找到重复的 PPA 定义，退出函数
  if [[ -z "$duplicates" ]]; then
    echo "没有找到重复的 PPA 定义。"
    rm "$temp_file"
    return
  fi

  # 遍历重复的 PPA 定义并删除重复的条目
  echo "$duplicates" | while read -r duplicate; do
    # 查找包含重复 PPA 定义的文件
    files=$(grep -F ":$duplicate" "$temp_file" | cut -d: -f1 | sort | uniq)

    echo "包含重复 PPA 定义的文件:"
    echo "$files"

    # 保留第一个文件中的定义，删除其他文件中的重复定义
    first_file=true
    echo "$files" | while read -r file; do
      if $first_file; then
        first_file=false
      else
        echo "删除文件 $file 中的重复 PPA 定义: $duplicate"
        escaped_duplicate=$(printf '%s\n' "$duplicate" | sed 's/[]\/$*.^|[]/\\&/g')
        sudo sed -i "\|$escaped_duplicate|d" "$file"
      fi
    done
  done

  # 删除临时文件
  rm "$temp_file"
  echo "删除临时文件: $temp_file"
}

# 使用方法
# clean_duplicate_ppa

add_cmake_ppa() {
   wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
   local _local_version=get_ubuntu_version
   case "$_local_version" in
        "focal")
            echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ focal main' | sudo tee /etc/apt/sources.list.d/kitware.list >/dev/null
        ;;
        "jammy")
            echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main' | sudo tee /etc/apt/sources.list.d/kitware.list >/dev/null    
        ;;
        *)
            echo "Unkown ubuntu version"
        ;;
   esac
   sudo apt update
   sudo apt install -y kitware-archive-keyring
}

add_intel_ppa(){
        wget -O /tmp/intel-keyring.pub https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
        sudo apt-get add /tmp/intel-keyring.pub
        rm -rf /tmp/intel-keyring.pub
        sudo add-apt-repository "deb https://apt.repos.intel.com/oneapi all main"
}

update_missing_keys(){
   tmp="$(mktemp)"
   sudo apt-get update 2>&1 | sed -En 's/.*NO_PUBKEY ([[:xdigit:]]+).*/\1/p' | sort -u > "${tmp}"
   cat "${tmp}" | xargs sudo gpg --keyserver "hkps://keyserver.ubuntu.com:443" --recv-keys  # to /usr/share/keyrings/*
   cat "${tmp}" | xargs -L 1 sh -c 'sudo gpg --yes --output "/etc/apt/trusted.gpg.d/$1.gpg" --export "$1"' sh  # to /etc/apt/trusted.gpg.d/*
   rm "${tmp}"
}

