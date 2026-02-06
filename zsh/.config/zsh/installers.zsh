# Lazy install entrypoints for conditionally-loaded modules.
# Keep installer commands available even when runtime modules are not loaded.

_lazy_install_call() {
  local module="$1"
  local fn="$2"
  shift 2

  local module_path="$ZSH_CONF_DIR/$module"
  local before="${functions[$fn]-}"

  if [[ ! -f "$module_path" ]]; then
    echo "❌ module not found: $module_path"
    return 1
  fi

  source "$module_path"

  if [[ -z "${functions[$fn]-}" || "${functions[$fn]}" == "$before" ]]; then
    echo "❌ $fn is unavailable after sourcing $module"
    return 1
  fi

  "$fn" "$@"
}

install_docker_gpg_key() { _lazy_install_call "docker.zsh" "install_docker_gpg_key" "$@"; }
install_docker_apt_source() { _lazy_install_call "docker.zsh" "install_docker_apt_source" "$@"; }
install_docker_apt_source_tuna() { _lazy_install_call "docker.zsh" "install_docker_apt_source_tuna" "$@"; }
install_docker_smart() { _lazy_install_call "docker.zsh" "install_docker_smart" "$@"; }
install_docker_apt() { _lazy_install_call "docker.zsh" "install_docker_apt" "$@"; }
install_docker_lsp() { _lazy_install_call "docker.zsh" "install_docker_lsp" "$@"; }

install_yamlfmt() { _lazy_install_call "golang.zsh" "install_yamlfmt" "$@"; }
install_yaml_lsp() { _lazy_install_call "golang.zsh" "install_yaml_lsp" "$@"; }
install_yaml_lint() { _lazy_install_call "golang.zsh" "install_yaml_lint" "$@"; }
install_gotools_goreleaser() { _lazy_install_call "golang.zsh" "install_gotools_goreleaser" "$@"; }
install_golang_ppa() { _lazy_install_call "golang.zsh" "install_golang_ppa" "$@"; }

install_rustup() { _lazy_install_call "rust.zsh" "install_rustup" "$@"; }
install_rust_analyzer() { _lazy_install_call "rust.zsh" "install_rust_analyzer" "$@"; }
install_rust_tools() { _lazy_install_call "rust.zsh" "install_rust_tools" "$@"; }
install_toml_lsp() { _lazy_install_call "rust.zsh" "install_toml_lsp" "$@"; }

install_pyenv() { _lazy_install_call "python.zsh" "install_pyenv" "$@"; }
install_python_tools() { _lazy_install_call "python.zsh" "install_python_tools" "$@"; }
install_python_rust_tools() { _lazy_install_call "python.zsh" "install_python_rust_tools" "$@"; }
install_latest_python_ppa() { _lazy_install_call "python.zsh" "install_latest_python_ppa" "$@"; }
install_pip() { _lazy_install_call "python.zsh" "install_pip" "$@"; }
install_pythontools_uv() { _lazy_install_call "python.zsh" "install_pythontools_uv" "$@"; }
install_pythontools_minimamba() { _lazy_install_call "python.zsh" "install_pythontools_minimamba" "$@"; }
install_pixi() { _lazy_install_call "python.zsh" "install_pixi" "$@"; }

install_fnm() { _lazy_install_call "node.zsh" "install_fnm" "$@"; }
install_nvm() { _lazy_install_call "node.zsh" "install_nvm" "$@"; }
install_node() { _lazy_install_call "node.zsh" "install_node" "$@"; }
install_nodesource_ppa() { _lazy_install_call "node.zsh" "install_nodesource_ppa" "$@"; }

install_zulu_jdk() { _lazy_install_call "java.zsh" "install_zulu_jdk" "$@"; }

install_cpp_tools_in_python() { _lazy_install_call "cc.zsh" "install_cpp_tools_in_python" "$@"; }
install_cpp_tools_in_rust() { _lazy_install_call "cc.zsh" "install_cpp_tools_in_rust" "$@"; }
install_cpp_tools_cppcheck() { _lazy_install_call "cc.zsh" "install_cpp_tools_cppcheck" "$@"; }
install_latest_gcc_ppa() { _lazy_install_call "cc.zsh" "install_latest_gcc_ppa" "$@"; }
install_latest_clang_ppa() { _lazy_install_call "cc.zsh" "install_latest_clang_ppa" "$@"; }

install_cuda_ppa() { _lazy_install_call "cuda.zsh" "install_cuda_ppa" "$@"; }

install_wasmtime_proxy() { _lazy_install_call "wasm.zsh" "install_wasmtime_proxy" "$@"; }
install_wasmtime() { _lazy_install_call "wasm.zsh" "install_wasmtime" "$@"; }

install_zls() { _lazy_install_call "zig.zsh" "install_zls" "$@"; }
install_zigmod() { _lazy_install_call "zig.zsh" "install_zigmod" "$@"; }
install_zigup() { _lazy_install_call "zig.zsh" "install_zigup" "$@"; }
install_zigup_proxy() { _lazy_install_call "zig.zsh" "install_zigup_proxy" "$@"; }
install_zig() { _lazy_install_call "zig.zsh" "install_zig" "$@"; }

install_svls() { _lazy_install_call "hdl.zsh" "install_svls" "$@"; }
install_verible() { _lazy_install_call "hdl.zsh" "install_verible" "$@"; }
install_hdl_checker() { _lazy_install_call "hdl.zsh" "install_hdl_checker" "$@"; }
install_hdl_tools() { _lazy_install_call "hdl.zsh" "install_hdl_tools" "$@"; }
install_iverilog() { _lazy_install_call "hdl.zsh" "install_iverilog" "$@"; }

install_ros2() { _lazy_install_call "ros.zsh" "install_ros2" "$@"; }

install_gtsam() { _lazy_install_call "robotics.zsh" "install_gtsam" "$@"; }
install_g2o() { _lazy_install_call "robotics.zsh" "install_g2o" "$@"; }
install_ceres_v1() { _lazy_install_call "robotics.zsh" "install_ceres_v1" "$@"; }
install_ceres_v2() { _lazy_install_call "robotics.zsh" "install_ceres_v2" "$@"; }
install_robotics_deps() { _lazy_install_call "robotics.zsh" "install_robotics_deps" "$@"; }

add_cuda_ppa() { _lazy_install_call "cuda.zsh" "add_cuda_ppa" "$@"; }
add_cuda_ppa_cn() { _lazy_install_call "cuda.zsh" "add_cuda_ppa_cn" "$@"; }
add_python_ppa() { _lazy_install_call "python.zsh" "add_python_ppa" "$@"; }
add_golang_ppa() { _lazy_install_call "golang.zsh" "add_golang_ppa" "$@"; }
add_zulu_ppa() { _lazy_install_call "java.zsh" "add_zulu_ppa" "$@"; }
add_clang_ppa() { _lazy_install_call "cc.zsh" "add_clang_ppa" "$@"; }
add_nodesource_ppa() { _lazy_install_call "node.zsh" "add_nodesource_ppa" "$@"; }

install_help() {
  local tool="$1"
  if [[ -z "$tool" ]]; then
    echo "Usage: install_help <tool>"
    return 1
  fi

  if ! command -v install_catalog_normalize_tool >/dev/null 2>&1; then
    echo "install catalog not loaded"
    return 1
  fi

  local normalized
  normalized="$(install_catalog_normalize_tool "$tool")"
  local policy="${INSTALL_POLICY:-latest}"
  local methods
  methods="$(install_catalog_methods "$normalized" "$policy" 2>/dev/null)" || methods="(not cataloged)"
  local binary
  binary="$(install_catalog_binary "$normalized" 2>/dev/null || true)"
  local min_version
  min_version="$(install_catalog_min_version "$normalized" 2>/dev/null || true)"

  echo "tool: $normalized"
  echo "policy: $policy"
  echo "forced method: ${INSTALL_METHOD:-auto}"
  echo "method order: $methods"
  [[ -n "$binary" ]] && echo "version binary: $binary"
  [[ -n "$min_version" ]] && echo "minimum version: $min_version"
}
