install_gtsam() {
        echo "=====install/update gtsam========="
        local _localtion_url="https://github.com/borglab/gtsam.git"
        local _localtion_path="$HOME/Source/app/borglab/gtsam"
        if [[ ! -d "${_localtion_path}" ]]; then
                git clone --recursive $_localtion_url $_localtion_path
                cd $_localtion_path
                git checkout 4.1.1
        else
                cd $_localtion_path
                echo "======= dir already exist, git pull=========="
                git checkout 4.1.1
                git pull
        fi

        cd $_localtion_path

        local _install_dir
        # if argument is large than 1, then use the argument as the build path
        if [[ $# -gt 0 ]]; then
                echo "$1"
                case $1 in
                local)
                        _install_dir="${HOME}/.local"
                        ;;
                global)
                        _install_dir="/usr/local"
                        ;;
                *)
                        _install_dir="${HOME}/.local"
                        ;;
                esac
        else
                _install_dir="${HOME}/.local"
        fi

        echo "===install path: ${_install_dir}"

        cmake -S . -B build/release -G Ninja -DCMAKE_INSTALL_PREFIX=$_install_dir -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
        cmake --build build/release -j$(nproc)

        cmake --install build/release

        if [[ $# -gt 0 ]]; then
                echo "$1"
                case $1 in
                local)
                        cmake --install build/release
                        ;;
                global)
                        sudo cmake --install build/release
                        ;;
                *)
                        cmake --install build/release
                        ;;
                esac
        else
                cmake --install build/release
        fi
}

install_g2o() {
        echo "=====install/update g2o========="
        local _localtion_url="https://github.com/RainerKuemmerle/g2o.git"
        local _localtion_path="$HOME/Source/app/RainerKuemmerle/g2o.git"
        if [[ ! -d "${_localtion_path}" ]]; then
                git clone --recursive $_localtion_url $_localtion_path
                cd $_localtion_path
                git checkout 20201223_git
        else
                cd $_localtion_path
                echo "======= dir already exist, git pull=========="
                git checkout 20201223_git
                git pull
        fi

        cd $_localtion_path

        local _install_dir
        # if argument is large than 1, then use the argument as the build path
        if [[ $# -gt 0 ]]; then
                echo "$1"
                case $1 in
                local)
                        _install_dir="${HOME}/.local"
                        ;;
                global)
                        _install_dir="/usr/local"
                        ;;
                *)
                        _install_dir="${HOME}/.local"
                        ;;
                esac
        else
                _install_dir="${HOME}/.local"
        fi

        echo "===install path: ${_install_dir}"

        cmake -S . -B build/release -G Ninja -DCMAKE_INSTALL_PREFIX=$_install_dir -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
        cmake --build build/release -j$(nproc)

        cmake --install build/release

        if [[ $# -gt 0 ]]; then
                echo "$1"
                case $1 in
                local)
                        cmake --install build/release
                        ;;
                global)
                        sudo cmake --install build/release
                        ;;
                *)
                        cmake --install build/release
                        ;;
                esac
        else
                cmake --install build/release
        fi
}

install_ceres_v1() {

}

install_ceres_v2() {

}

install_robotics_deps() {
        sudo apt install -y libopenblas-dev libsuitesparse-dev
}