# c++ related config

export CC_SRC_DIR="cd $HOME/Source/langs/c++"

alias CCDIR="cd $CC_SRC_DIR"

export LD_LIBRARY_PATH=$HOME/usr/lib:$HOME/usr/local/lib:/usr/local/lib:/usr/lib:$LD_LIBRARY_PATH
export LIBRARY_PATH=$HOME/usr/lib:$HOME/usr/local/lib:/usr/local/lib:/usr/lib:$LIBRARY_PATH
export C_INCLUDE_PATH=$HOME/usr/local/include:$HOME/usr/include:/usr/local/include:/usr/include:$C_INCLUDE_PATH
export CPP_INCLUDE_PATH=$HOME/usr/local/include:$HOME/usr/include:/usr/local/include:/usr/include:$CPP_INCLUDE_PATH
# export LDFLAGS="-L/usr/local/opt/qt/lib:-L/usr/local/lib:$LDFLAGS"
# export CFLAGS="-I/usr/local/opt/qt/include:-I/usr/local/include:-I/usr/include:$CFLAGS"
# export CPPFLAGS="-I/usr/local/opt/qt/include:-I/usr/local/include:-I/usr/include:$CPPFLAGS"



alias _cmk='cmake -G "Ninja"'

function _cmninja(){
    if [[ ${USE_VCPKG} = "ON" ]] ;
    then
        alias _cmk="cmake -G 'Ninja' -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_TOOLCHAIN_FILE=${VCPKG_CMAKE_PATH}"
    else
        alias _cmk='cmake -G "Ninja" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON'
    fi
}

function _cmmake(){
    alias _cmk='cmake -G "Unix Makefiles"'
}

function _cmdebug()
{
    _cmk -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Debug -B build/debug "$@"
}

function _cmrelease(){
    _cmk -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Release -B build/release "$@"
}

function cmdebug(){
    _cmdebug "$@"
    cmake --build build/debug -j "$(nproc)"
}

function cmbuild() {
	cmake --build build -j "$(nproc)"
}

function cminsrel(){
	cmake --install build/release
}

function cminsdebug() {
    cmake --install build/debug
}

function cmrelease(){
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
	g++ --std=c++17 -Wall -Wextra -g -o "${1}.g.out" "${1}"
}

function g++r() {
	g++ --std=c++17 -Wall -Wextra -g -o "${1}.g.out" "${1}"
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
	clang++ --std=c++17 -Wall -Wextra -g -o "${1}.c.out" "${1}"
	./"${1}.c.out"
}

function install_ctags() {
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
  make
  make install # may require extra privileges depending on where to install

}

function install_cpp_tools(){
  mkdir -p $HOME/Source/app

  local _pip_tools=(
    "cmake-format"
    "cmakelang"
    "gersemi"
    "cmake-language-server"
    "cpplint"
  )
  echo $PWD
	echo update cpp tools
	for _cpp_pip_tool in $_pip_tools; do
		echo update go install tools: $_cpp_pip_tool
    pip install -i https://pypi.tuna.tsinghua.edu.cn/simple -U --user $_cpp_pip_tool 
	done

  echo "================finish=========="

  local _cpp_cmake_install_tools=(
    "danmar/cppcheck"
    "rizsotto/Bear"
  )

  echo $PWD
  echo "============================="
  echo "update cpp cmake install tools"
  for _cpp_install_tool in $_cpp_cmake_install_tools; do
    echo "update ${_cpp_install_tool}"
    local _localtion_url="https://github.com/${_cpp_install_tool}"
    local _localtion_path="$HOME/Source/app/${_cpp_install_tool}"
    echo $_localtion_path
    echo $_localtion_url
    if [[ ! -d "${_localtion_path}" ]]; then
      git clone --recursive $_localtion_url $_localtion_path
    else
      cd $_localtion_path
      git pull
    fi

    echo "build tools"
    cd $_localtion_path
    cmake -B build/release -G Ninja -DCMAKE_INSTALL_PREFIX=$HOME/.local -DCMAKE_BUILD_TYPE=Release
    cmake --build build/release -j $(nproc)
    cmake --install build/release
  done
}
