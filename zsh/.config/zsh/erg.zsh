# @brief Install Erg programming language compiler
# @return 0 on success, 1 if cargo not available
# @example install_erg
# @category erg
install_erg(){
        # if command line cargo is not installed
        if ! command -v cargo &> /dev/null; then
                echo "cargo could not be found"
                echo "please cargo"
                exit
        fi
        echo "=====Installing erg====="
        cargo install erg
        echo "=====erg installed====="
}