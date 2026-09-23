install_ser_bbr() {
  if command -v curl &>/dev/null; then
    bash <(curl -fsSL https://raw.githubusercontent.com/byJoey/Actions-bbr-v3/main/install.sh)
  else
    echo "curl is not installed"
  fi
}
