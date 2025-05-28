# @brief Install GTSAM (Georgia Tech Smoothing and Mapping library)
# @param $1 Installation scope (local|global, default: local)
# @return 0 on success
# @example install_gtsam local
# @category robotics
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

# @brief Install g2o (General Graph Optimization library)
# @param $1 Installation scope (local|global, default: local)
# @return 0 on success
# @example install_g2o local
# @category robotics
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

# @brief Install Ceres Solver v1 (non-linear optimization library)
# @return 0 on success
# @example install_ceres_v1
# @category robotics
install_ceres_v1() {
    echo "⚠️  install_ceres_v1 not implemented yet"
    return 1
}

# @brief Install Ceres Solver v2 (non-linear optimization library)
# @return 0 on success
# @example install_ceres_v2
# @category robotics
install_ceres_v2() {
    echo "⚠️  install_ceres_v2 not implemented yet"
    return 1
}

# @brief Install essential robotics development dependencies
# @return 0 on success
# @example install_robotics_deps
# @category robotics
install_robotics_deps() {
        sudo apt install -y libopenblas-dev libsuitesparse-dev
}