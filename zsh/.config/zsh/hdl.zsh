


# ================== Install Tools =======================
install_svls() {
        cargo install svls
}

install_verible() {
        local _versible_version=$(GetLatestRelease "chipsalliance/verible")

        local _base_url="https://github.com/chipsalliance/verible/releases/download/v${_versible_version}/verible-v${_versible_version}"
        # https://github.com/chipsalliance/verible/releases/download/v0.0-2371-g73fcce82/verible-v0.0-2371-g73fcce82-Ubuntu-16.04-xenial-x86_64.tar.gz
        local _common_end="x86_64.tar.gz"
        if [ -n "$(ls /etc | grep apt)" ]; then
                CODENAME=$(lsb_release -c | awk '{print $2}')

                case "$CODENAME" in
                "bionic")
                        wget -O ~/Source/app/verible_latest.tar.gz "${_base_url}-Ubuntu-18.04-bionic-${_common_end}"
                        ;;
                "focal")
                        wget -O ~/Source/app/verible_latest.tar.gz "${_base_url}-Ubuntu-20.04-focal-${_common_end}"
                        ;;
                "jammy")
                        wget -O ~/Source/app/verible_latest.tar.gz "${_base_url}-Ubuntu-22.04-jammy-${_common_end}"
                        ;;
                *)
                        echo "Unsupport ubuntu version!"
                        exit 1
                        ;;
                esac
        elif [ -n "$(ls /etc | grep yum) "]; then
                wget -O ~/Source/app/verible_latest.tar.gz "${_base_url}-CentOS-7.9.2009-Core-${_common_end}"
        else
                echo "install_verible only working for Ubuntu and CentOS, you can build from source by youself "
                exit 1
        fi

        cd ~/Source/app
        tar xvf ~/Source/app/verible_latest.tar.gz
        cd "verible-v${_versible_version}"
        sudo cp -r bin/* /usr/local/bin/
        sudo mkdir -p /usr/local/share/man/man1
        sudo cp -r share/man/man1/* /usr/local/share/man/man1
        sudo cp -r share/verible /usr/local/share/
        echo "==========================="
        echo "====== Install Finish ====="
}

install_hdl_checker() {
        python3 -m pip install hdl-checker --user --upgrade
}

install_hdl_tools() {
        install_svls
        install_verible
        install_hdl_checker
}

install_iverilog() {
        pki gperf flex bison
        git clone --recurse-submodules --depth 1 https://github.com/steveicarus/iverilog.git $HOME/Source/app/iverilog

        cd $HOME/Source/app/iverilog

        sh autoconf.sh
        ./configure --prefix=/usr/local
        make -j $(nproc)
        sudo make install
}
