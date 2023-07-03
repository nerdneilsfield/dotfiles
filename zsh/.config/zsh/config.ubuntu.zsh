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

change_ppa_source() {
  for file in `ls /etc/apt/sources.list.d/`; do 
     if grep -q "ppa.launchpad.net" /etc/apt/sources.list.d/$file; then
           echo find ppa in $file
           awk '/^deb / {print "#"$1; sub("http://ppa.launchpad.net/", "https://launchpad.proxy.ustclug.org/", $0); print} !/^deb / {print}' /etc/apt/sources.list.d/$file | sudo tee /etc/apt/sources.list.d/$file;
     fi
  done
}

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

update_missing_keys(){
   tmp="$(mktemp)"
   sudo apt-get update 2>&1 | sed -En 's/.*NO_PUBKEY ([[:xdigit:]]+).*/\1/p' | sort -u > "${tmp}"
   cat "${tmp}" | xargs sudo gpg --keyserver "hkps://keyserver.ubuntu.com:443" --recv-keys  # to /usr/share/keyrings/*
   cat "${tmp}" | xargs -L 1 sh -c 'sudo gpg --yes --output "/etc/apt/trusted.gpg.d/$1.gpg" --export "$1"' sh  # to /etc/apt/trusted.gpg.d/*
   rm "${tmp}"
}

