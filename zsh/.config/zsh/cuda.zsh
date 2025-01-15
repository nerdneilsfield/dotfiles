add_cuda_ppa(){
    sudo apt install -y software-properties-common
    
    # get ubuntu version
    VERSION_NUMBER=$(lsb_release -r | awk '{print $2}')
    ARCHTERCTURE=$(uname -m)

    echo "-----import key---------"
    sudo apt-key adv --fetch-keys "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu${VERSION_NUMBER}/${ARCHTERCTURE}/3bf863cc.pub"

    echo "-----add apt repository---------"
    sudo bash -c "echo deb\ http://developer.download.nvidia.com/compute/cuda/repos/${VERSION_NUMBER}/${ARCHITECTURE}/\ / > /etc/apt/sources.list.d/cuda.list"

    echo "-----update apt---------"
    sudo apt update
}

add_cuda_ppa_cn(){
    sudo apt install -y software-properties-common
    
    # get ubuntu version
    VERSION_NUMBER=$(lsb_release -r | awk '{print $2}')
    ARCHTERCTURE=$(uname -m)

    echo "-----import key---------"
    sudo apt-key adv --fetch-keys "https://developer.download.nvidia.cn/compute/cuda/repos/ubuntu${VERSION_NUMBER}/${ARCHTERCTURE}/3bf863cc.pub"

    echo "-----add apt repository---------"
    sudo bash -c "echo deb\ http://developer.download.nvidia.cn/compute/cuda/repos/${VERSION_NUMBER}/${ARCHITECTURE}/\ / > /etc/apt/sources.list.d/cuda.list"

    echo "-----update apt---------"
    sudo apt update
}

install_cuda_ppa(){
    sudo apt install -y cuda
}


# test the cuda path exists and nvcc works
test_cuda_path(){
    if [ -d "/usr/local/cuda" ]; then
        if [ -d "/usr/local/cuda/bin/nvcc" ]; then
            return true
        else
            return false
        fi
    else
        return false
    fi
}

__is_cuda_exists=$(test_cuda_path)
if $__is_cuda_exists; then
    echo "CUDA path exists and nvcc works, enable cuda"
    export PATH=/usr/local/cuda/bin:$PATH
    export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
    export CUDA_HOME=/usr/local/cuda
else
    echo "CUDA path does not exist or nvcc does not work, disable cuda"
fi