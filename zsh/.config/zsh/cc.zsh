# c++ related config

export CC_SRC_DIR="cd $HOME/Source/langs/c++"

alias CCDIR="cd $CC_SRC_DIR"

export CMAKE_PREFIX_PATH=$HOME/.local/lib/cmake:$CMAKE_PREFIX_PATH

export LD_LIBRARY_PATH=$HOME/.local/lib:/usr/local/lib:/usr/lib
export LIBRARY_PATH=$HOME/.local/lib:/usr/local/lib:/usr/lib
export C_INCLUDE_PATH=$HOME/.local/include:/usr/local/include:/usr/include
export CPP_INCLUDE_PATH=$HOME/.local/include:/usr/local/include:/usr/include
# export LDFLAGS="-L/usr/local/opt/qt/lib:-L/usr/local/lib:$LDFLAGS"
# export CFLAGS="-I/usr/local/opt/qt/include:-I/usr/local/include:-I/usr/include:$CFLAGS"
# export CPPFLAGS="-I/usr/local/opt/qt/include:-I/usr/local/include:-I/usr/include:$CPPFLAGS"

find_latest_cc_compilers() {
  # 初始化数组来存储找到的 GCC 和 Clang 版本
  gcc_versions=()
  clang_versions=()

  # 遍历 $PATH 中的所有目录
  for dir in ${(s/:/)PATH}; do
    # 检查目录是否存在
    if [[ -d $dir ]]; then
      # 查找以 gcc- 开头且只包含数字的可执行文件
      for file in $dir/gcc-<->(N); do
        # 检查文件是否存在且可执行
        if [[ -x $file ]]; then
          gcc_versions+=($file:t)
        fi
      done
      # 查找以 clang- 开头且只包含数字的可执行文件
      for file in $dir/clang-<->(N); do
        # 检查文件是否存在且可执行
        if [[ -x $file ]]; then
          clang_versions+=($file:t)
        fi
      done
    fi
  done

  # 如果没有找到任何 GCC 版本，使用系统默认的 gcc
  if [[ ${#gcc_versions[@]} -eq 0 ]]; then
    export GCC=$(which gcc)
    export GXX=$(which g++)
  else
    # 找到最新的 GCC 版本
    latest_gcc=$(printf "%s\n" "${gcc_versions[@]}" | sort -V | tail -n 1)
    export GCC=$(which $latest_gcc)
    export GXX=$(which ${latest_gcc/gcc/g++})
  fi

  # 如果没有找到任何 Clang 版本，使用系统默认的 clang
  if [[ ${#clang_versions[@]} -eq 0 ]]; then
    export CLANG=$(which clang)
    export CLANGXX=$(which clang++)
  else
    # 找到最新的 Clang 版本
    latest_clang=$(printf "%s\n" "${clang_versions[@]}" | sort -V | tail -n 1)
    export CLANG=$(which $latest_clang)
    export CLANGXX=$(which ${latest_clang/clang/clang++})
  fi

  # 输出设置的编译器版本
  green_echo "设置 GCC 版本为: $GCC"
  green_echo "设置 GXX 版本为: $GXX"
  green_echo "设置 CLANG 版本为: $CLANG"
  green_echo "设置 CLANGXX 版本为: $CLANGXX"
}

# 使用方法
# 运行 find_latest_compilers 函数
find_latest_cc_compilers


alias _cmk='cmake -G "Ninja"'

function _cmninja() {
  if [[ ${USE_VCPKG} = "ON" ]]; then
    alias _cmk="cmake -G 'Ninja' -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_TOOLCHAIN_FILE=${VCPKG_CMAKE_PATH}"
  else
    alias _cmk='cmake -G "Ninja" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON'
  fi
}

function _cmmake() {
  alias _cmk='cmake -G "Unix Makefiles"'
}

function _cmdebug() {
  _cmk -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Debug -B build/debug "$@"
}

function _cmrelease() {
  _cmk -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Release -B build/release "$@"
}

function cmdebug() {
  _cmdebug "$@"
  cmake --build build/debug -j "$(nproc)"
}

function cmbuild() {
  cmake --build build -j "$(nproc)"
}

function cminsrel() {
  cmake --install build/release
}

function cminsdebug() {
  cmake --install build/debug
}

function cmrelease() {
  _cmrelease
  cmake --build build/release -j$(nproc)
}

function gcco() {
  gcc --std=c11 -Wall -Wextra -g -o "${1}.g.out" "${1}"
}

function gccr() {
  gcc --std=c11 -Wall -Wextra -g -o "${1}.g.out" "${1}"
  ./"${1}.g.out"
}

function g++o() {
  g++ --std=c++20 -Wall -Wextra -g -o "${1}.g.out" "${1}"
}

function g++r() {
  g++ --std=c++20 -Wall -Wextra -g -o "${1}.g.out" "${1}"
  ./"${1}.g.out"
}

function clango() {
  clang --std=c11 -Wall -Wextra -g -o "${1}.c.out" "${1}"
}

function clangr() {
  clang --std=c11 -Wall -Wextra -g -o "${1}.c.out" "${1}"
  ./"${1}.c.out"
}

function clang++r() {
  clang++ --std=c++20 -Wall -Wextra -g -o "${1}.c.out" "${1}"
  ./"${1}.c.out"
}

function install_cpp_tools_ctags() {
  echo "=====install/update ctags========="
  local _localtion_url="https://github.com/universal-ctags/ctags.git"
  local _localtion_path="$HOME/Source/app/universal-ctags/ctags"

  echo $_localtion_path
  if [[ ! -d "${_localtion_path}" ]]; then
    git clone --recursive $_localtion_url $_localtion_path
  else
    cd $_localtion_path
    git pull
  fi

  echo "----build ctags-------"
  cd $_localtion_path
  ./autogen.sh
  ./configure --prefix=$HOME/.local
  sed -i "1 i #define SETLOCALE_NULL_MAX 0" gnulib/hard-locale.c
  export CC=gcc
  make
  make install # may require extra privileges depending on where to install

}

function install_cpp_tools_mold() {
  echo "=====install/update mold========="
  set_cxx clang
  mkdir -p $HOME/Source/app
  if [ -d "$HOME/Source/app/mold" ]; then
    cd $HOME/Source/app/mold
    git pull
  else
    git clone --depth 1 https://github.com/rui314/mold.git $HOME/Source/app/mold
  fi
  cd $HOME/Source/app/mold
  rm -rf build
  cmake -S . -B build -DCMAKE_INSTALL_PREFIX=$HOME/.local -DCMAKE_BUILD_TYPE=Release -G Ninja
  cmake --build build -j$(nproc)
  cmake --install build
}

function install_cpp_tools_fccf() {
  mkdir -p $HOME/Source/app
  green_echo "=====install/update fccf========="
  # if [  -n "$(ls /etc | grep apt)" ]; then
  #   sudo apt install  
  # elif [  -n "$(ls /etc | grep apt)" ]; then
  #   yellow_echo "Un-support distribution of linux...."
  # fi
  if [ -d "$HOME/Source/app/fccf" ]; then
    cd $HOME/Source/app/fccf
    git pull
  else
    git clone --depth 1 --recursive https://github.com/p-ranav/fccf $HOME/Source/app/fccf
  fi
  cd $HOME/Source/app/fccf
  rm -rf build
  set_cxx clang
  set_ld mold
  cmake -S . -B build -D CMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_INSTALL_PREFIX=$HOME/.local -DCMAKE_CXX_LINK_EXECUTABLE="mold <LINK_FLAGS> <OBJECTS> -o <TARGET>"
  cmake --build build -j$(nproc)
  cmake --install build
}

function install_cpp_tools_vtune() {
  if [  -n "$(ls /etc | grep apt)" ]; then
    sudo apt install intel-oneapi-vtune
  elif [  -n "$(ls /etc | grep apt)" ]; then
    yay -S intel-oneapi-basekit
  fi
}

install_cpp_tools_in_python() {
  local _pip_tools=(
    "cmakelang"
    "gersemi"
    "cmake-language-server"
    "cpplint"
  )
  echo $PWD
  echo update cpp tools
  for _cpp_pip_tool in $_pip_tools; do
    echo update go install tools: $_cpp_pip_tool
    python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple -U --user $_cpp_pip_tool
  done
}

install_cpp_tools_in_rust() {
  local _cargo_tools=(
    "sccache"
  )
  echo $PWD
  echo update cpp tools in rust
  for _cpp_cargo_tool in $_cargo_tools; do
    echo update go install tools: $_cpp_cargo_tool
    cins sccache
  done
}

install_cpp_tools_cppcheck() {
  echo "=====install/update cppcheck========="
  local _localtion_url="https://github.com/danmar/cppcheck.git"
  local _localtion_path="$HOME/Source/app/danmar/cppcheck"
  if [[ ! -d "${_localtion_path}" ]]; then
    git clone --recursive --depth 1 $_localtion_url $_localtion_path
  else
    cd $_localtion_path
    git pull
  fi

  cd $_localtion_path
  cmake -S . -B build/release -G Ninja -DCMAKE_INSTALL_PREFIX=$HOME/.local -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
  cmake --build build/release -j$(nproc)
  cmake --install build/release
}

function install_cpp_tools_iwyu() {
  # echo "=====install/update include-what-you-use========="
  # local _localtion_url="https://github.com/include-what-you-use/include-what-you-use.git"
  # local _localtion_path="$HOME/Source/app/include-what-you-use/include-what-you-use"
  # if [[ ! -d "${_localtion_path}" ]]; then
  #   git clone --recursive --depth 1 $_localtion_url $_localtion_path
  # else
  #   cd $_localtion_path
  #   git pull
  # fi

  # cd $_localtion_path
  # cmake -S . -B build/release -G Ninja -DCMAKE_INSTALL_PREFIX=$HOME/.local -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
  # cmake --build build/release -j$(nproc)
  # cmake --install build/release
  pki -y iwyu
}

function install_cpp_tools_build(){
  pki ccache cmake make gdb pkg-config coreutils
}

function install_cpp_tools_rr(){
  # if system is ubuntu
  if [  -n "$(ls /etc | grep apt)" ]; then
    sudo apt-get install -y g++-multilib \
       python3-pexpect manpages-dev capnproto libcapnp-dev zlib1g-dev
  elif [ -n "$(ls /etc | grep pacman)" ]; then
    sudo pacman -S  python-pexpect capnproto
  else
    echo "Un-support distribution of linux...."
    exit 0
  fi

  make -p $HOME/Source/app
  local _localtion_path="$HOME/Source/app/rr-debugger/rr"
  local _localtion_url="https://github.com/rr-debugger/rr"

  if [[ ! -d "${_localtion_path}" ]]; then
    git clone --recursive --depth 1 $_localtion_url $_localtion_path
  else
    cd $_localtion_path
    git pull
  fi

  cd $_localtion_path
  rm -rf build/release
  set_cxx clang
  set_ld mold
  cmake -S . -B build/release -G Ninja -DCMAKE_INSTALL_PREFIX=$HOME/.local -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON  -DCMAKE_LINKER=mold
  cmake --build build/release -j$(nproc)
  cmake --install build/release
}

function install_cpp_tools_bear() {
  echo "=====install/update bear========="
  local _localtion_url="https://github.com/rizsotto/Bear.git"
  local _localtion_path="$HOME/Source/app/rizsotto/Bear"
  if [[ ! -d "${_localtion_path}" ]]; then
    git clone --recursive --depth 1 $_localtion_url $_localtion_path
  else
    cd $_localtion_path
    git pull
  fi

  cd $_localtion_path
  set_cxx clang
  rm -rf build/release
  cmake -S . -B build/release -G Ninja -DCMAKE_INSTALL_PREFIX=$HOME/.local -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
  cmake --build build/release -j$(nproc)
  cmake --install build/release
}

function install_cpp_tools_xmake() {
  echo "=====install/update xmake========="
  local _localtion_url="https://github.com/xmake-io/xmake"
  local _localtion_path="$HOME/Source/app/xmake-io/xmake"

  if [[ ! -d "${_localtion_path}" ]]; then
    git clone --recursive --depth 1 $_localtion_url $_localtion_path
  else
    cd $_localtion_path
    git pull
  fi

  cd $_localtion_path
  set_cxx clang
  set_ld mold
  ./configure
  make clean
  make -j$(nproc)
  ./scripts/get.sh __local__ __install_only__
}

function install_cpp_tools() {
  mkdir -p $HOME/Source/app

  install_cpp_tools_in_python
  install_cpp_tools_in_rust
  install_cpp_tools_mold

  install_cpp_tools_cppcheck
  install_cpp_tools_bear
}

function set_cxx(){
  case "$1" in
    "gcc")
      green_echo "Change to gcc"
      export CC=$GCC
      export CXX=$GXX
    ;;
    "clang")
     green_echo "Change to clang"
      export CC=$CLANG
      export CXX=$CLANGXX
    ;;
    "distcc-clang")
      green_echo "change to distcc clang"
    if hash distcc 2>/dev/null; then
      export CC="distcc ${GLANG}"
      export CXX="distcc ${GLANGXX}"
    else
      green_echo "distcc not found"
    fi
    ;;
    "distcc-gcc")
    green_echo "change to distcc gcc"
    if hash distcc 2>/dev/null; then
      export CC="distcc ${GCC}"
      export CXX="distcc ${GXX}"
    else
      green_echo "distcc not found"
    fi
    ;;
    "zig")
      green_echo "change to zig"
      export CC="zig cc"
      export CXX="zig c++"
    ;;
    *)
      green_echo "useage: set_cxx [gcc|clang]"
    ;;
  esac
}

install_latest_gcc_ppa() {
  # 使用 apt search 查找所有可用的 GCC 版本
  local _available_gcc_versions=$(apt search gcc | grep -oP 'gcc-\d{2}(?=\s|/)' | sort -V | uniq)

  # 查找版本号最大的 GCC 版本
  local _latest_gcc_version=$(green_echo "$_available_gcc_versions" | tail -n 1)

  # 如果找不到任何 GCC 版本，输出错误信息并退出
  if [[ -z "$_latest_gcc_version" ]]; then
    yellow_echo "未找到可用的 GCC 版本。"
    return 1
  fi

  green_echo "找到的最新 GCC 版本: $_latest_gcc_version"

  # 提取版本号
  local _version_number=$(echo "$_latest_gcc_version" | grep -oP '\d+' | head -n 1)
  green_echo "提取的版本号: $_version_number"

  # 安装最新版本的 GCC 及其相关包
  sudo apt update
  sudo apt install -y "gcc-$_version_number" "g++-$_version_number" "gcc-$_version_number-multilib" "libgcc-$_version_number-dev" "libstdc++-$_version_number-dev" "libgomp1"

  green_echo "已成功安装 $_latest_gcc_version 及其相关包。"
}

install_latest_clang_ppa() {
    # 查找最新版本的 Clang
    local _available_versions
    _available_versions=$(apt search clang | grep -oP 'clang-\d{1,2}(?=\s|/)' | sort -V | uniq)
    local _latest_version
    _latest_version=$(echo "$_available_versions" | sort -V | tail -n 1)

    # 如果找不到任何 Clang 版本，输出错误信息并退出
    if [[ -z "$_latest_version" ]]; then
        yellow_echo "未找到可用的 Clang 版本。"
        return 1
    fi

    green_echo "找到的最新 Clang 版本: $_latest_version"

    # 提取版本号
    local _version_number
    _version_number=$(echo "$_latest_version" | grep -oP '\d+' | head -n 1)

    # 更新包列表
    sudo apt update

    # 安装 LLVM 相关包
    green_echo "# LLVM"
    sudo apt-get install -y "libllvm-${_version_number}-ocaml-dev" "libllvm${_version_number}" "llvm-${_version_number}" "llvm-${_version_number}-dev" "llvm-${_version_number}-doc" "llvm-${_version_number}-examples" "llvm-${_version_number}-runtime"

    # 安装 Clang 及相关包
    green_echo "# Clang and co"
    sudo apt-get install -y "clang-${_version_number}" "clang-tools-${_version_number}" "clang-${_version_number}-doc" "libclang-common-${_version_number}-dev" "libclang-${_version_number}-dev" "libclang1-${_version_number}" "clang-format-${_version_number}" "python3-clang-${_version_number}" "clangd-${_version_number}" "clang-tidy-${_version_number}"

    # 安装 compiler-rt
    green_echo "# compiler-rt"
    sudo apt-get install -y "libclang-rt-${_version_number}-dev"

    # 安装 polly
    green_echo "# polly"
    sudo apt-get install -y "libpolly-${_version_number}-dev"

    # 安装 libfuzzer
    green_echo "# libfuzzer"
    sudo apt-get install -y "libfuzzer-${_version_number}-dev"

    # 安装 lldb
    green_echo "# lldb"
    sudo apt-get install -y "lldb-${_version_number}"

    # 安装 lld (linker)
    green_echo "# lld (linker)"
    sudo apt-get install -y "lld-${_version_number}"

    # 安装 libc++
    green_echo "# libc++"
    sudo apt-get install -y "libc++-${_version_number}-dev" "libc++abi-${_version_number}-dev"

    # 安装 OpenMP
    green_echo "# OpenMP"
    sudo apt-get install -y "libomp-${_version_number}-dev"

    # 安装 libclc
    green_echo "# libclc"
    sudo apt-get install -y "libclc-${_version_number}-dev"

    # 安装 libunwind
    green_echo "# libunwind"
    sudo apt-get install -y "libunwind-${_version_number}-dev"

    # 安装 mlir
    green_echo "# mlir"
    sudo apt-get install -y "libmlir-${_version_number}-dev" "mlir-${_version_number}-tools"

    # 安装 bolt
    green_echo "# bolt"
    sudo apt-get install -y "libbolt-${_version_number}-dev" "bolt-${_version_number}"

    # 安装 flang
    green_echo "# flang"
    sudo apt-get install -y "flang-${_version_number}"

    # 安装 wasm support
    green_echo "# wasm support"
    sudo apt-get install -y "libclang-rt-${_version_number}-dev-wasm32" "libclang-rt-${_version_number}-dev-wasm64" "libc++-${_version_number}-dev-wasm32" "libc++abi-${_version_number}-dev-wasm32" "libclang-rt-${_version_number}-dev-wasm32" "libclang-rt-${_version_number}-dev-wasm64"

    # 安装 LLVM libc
    green_echo "# LLVM libc"
    sudo apt-get install -y "libllvmlibc-${_version_number}-dev"

    local _commands=$(compgen -c | grep '^llvm-.*-19')

    # 遍历匹配的命令并更新 alternatives
   for command in $_commands; do
        base_command=$(echo $command | sed "s/-$_version_number$//")
        sudo update-alternatives --install /usr/bin/$base_command $base_command /usr/bin/$command 100
   done

    # 单独处理 llvm-config
   sudo update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-$_version_number 100


   green_echo "已成功安装 Clang 及其相关包。"
}

function set_ld() {
  case "$1" in
    "gold")
      export LD=ld.gold
    ;;
    "lld")
      export LD=ld.lld
    ;;
    "mold")
      export LD=mold
    ;;
    *)
      export LD=ld
    ;;
  esac
}

if [[ -n "$(command -v xmake)" ]]; then
  source $HOME/.xmake/profile
fi
