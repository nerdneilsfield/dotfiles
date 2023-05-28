source_xrt() {
  source /opt/xilinx/xrt/setup.sh
}

source_vitis() {
  case "$1" in
    "2022.2"|"2022.1"|"2021.2"|"2021.1")
      source /tools/Xilinx/Vitis/$1/settings64.sh
      source /tools/Xilinx/Vivado/$1/settings64.sh
    ;;
    "-h")
      echo "Unknown version"
      echo "usage source_vitis [version:2022.2 etc]"
    ;;
    *)
      source /tools/Xilinx/Vitis/2022.2/settings64.sh
      source /tools/Xilinx/Vivado/2022.2/settings64.sh
    ;;
  esac
}

source_xilinx(){
  source_xrt
  source_vitis $1
}

check_vitis() {
  vitis --version
  echo "\n"
  v++ --version
  echo "\n"
  vivado -version
}
