# @brief Source Xilinx Runtime (XRT) environment
# @return 0 on success
# @example source_xrt
# @category xilinx
source_xrt() {
  source /opt/xilinx/xrt/setup.sh
}

# @brief Source Xilinx Vitis and Vivado environment
# @param $1 Version (2021.1|2021.2|2022.1|2022.2|2023.1|2023.2|2024.1|2024.2)
# @return 0 on success
# @example source_vitis 2024.1
# @category xilinx
source_vitis() {
  case "$1" in
    "2022.2"|"2022.1"|"2021.2"|"2021.1" | "2024.1" | "2024.2" | "2023.1" | "2023.2")
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

# @brief Source complete Xilinx development environment
# @param $1 Vitis version (optional)
# @return 0 on success
# @example source_xilinx 2024.1
# @category xilinx
source_xilinx(){
  source_xrt
  source_vitis $1
}

# @brief Check installed Xilinx tools versions
# @return 0 on success
# @example check_vitis
# @category xilinx
check_vitis() {
  vitis --version
  echo "\n"
  v++ --version
  echo "\n"
  vivado -version
}
