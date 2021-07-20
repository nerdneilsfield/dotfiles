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
    cmake --build build/release -j 'nproc'
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
