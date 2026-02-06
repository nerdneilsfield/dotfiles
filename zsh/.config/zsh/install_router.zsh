# Installer router with policy-based fallback

typeset -g INSTALL_POLICY="${INSTALL_POLICY:-latest}"
typeset -g INSTALL_METHOD="${INSTALL_METHOD:-auto}"
typeset -g INSTALL_VERBOSE="${INSTALL_VERBOSE:-1}"

install_trace() {
    local level="$1"
    shift
    if [[ "${INSTALL_VERBOSE:-1}" == "0" && "$level" != "error" ]]; then
        return 0
    fi
    echo "[install:$level] $*"
}

_install_version_extract() {
    local tool="$1"
    local binary="$2"
    local output version
    case "$tool" in
        fzf) output="$("$binary" --version 2>/dev/null)" ; version="${output%% *}" ;;
        ripgrep) output="$("$binary" --version 2>/dev/null | head -n1)" ; version="${output##* }" ;;
        fd) output="$("$binary" --version 2>/dev/null)" ; version="${output##* }" ;;
        bat) output="$("$binary" --version 2>/dev/null)" ; version="${output##* }" ;;
        eza) output="$("$binary" --version 2>/dev/null | head -n1)" ; version="${output##*v}" ;;
        lazygit) output="$("$binary" --version 2>/dev/null)" ; version="${output##*, version=}" ; version="${version%%,*}" ;;
        gh|zellij|yazi|btm|uv|ruff|pyenv|rustup|fnm)
            output="$("$binary" --version 2>/dev/null | head -n1)"
            version="$(echo "$output" | grep -Eo '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n1)"
            ;;
        *) return 1 ;;
    esac

    [[ -n "$version" ]] && echo "$version"
}

_install_version_ge() {
    local a="$1" b="$2"
    local IFS=.
    local -a av bv
    av=(${=a})
    bv=(${=b})
    local i max n1 n2
    max=${#av[@]}
    (( ${#bv[@]} > max )) && max=${#bv[@]}
    for ((i=1; i<=max; i++)); do
        n1=${av[i]:-0}
        n2=${bv[i]:-0}
        (( n1 > n2 )) && return 0
        (( n1 < n2 )) && return 1
    done
    return 0
}

install_version_check() {
    local tool="$1"
    local binary="$2"
    local min_version cur_version

    min_version="$(install_catalog_min_version "$tool" 2>/dev/null)" || return 0
    cur_version="$(_install_version_extract "$tool" "$binary")" || return 1
    _install_version_ge "$cur_version" "$min_version"
}

install_method_available() {
    local method="$1"
    local tool="$2"
    local pm

    case "$method" in
        pkg)
            pm="$(get_package_manager)"
            [[ "$pm" != "unknown" ]] && install_catalog_pkg_name "$tool" "$pm" >/dev/null 2>&1
            ;;
        registry)
            case "$(install_catalog_normalize_tool "$tool")" in
                ruff) command -v uv >/dev/null 2>&1 || command -v pip >/dev/null 2>&1 ;;
                yazi|bottom|fnm) command -v cargo >/dev/null 2>&1 ;;
                *) command -v cargo >/dev/null 2>&1 || command -v npm >/dev/null 2>&1 || command -v pip >/dev/null 2>&1 || command -v uv >/dev/null 2>&1 ;;
            esac
            ;;
        release|source)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

install_try_pkg() {
    local tool="$1"
    local pm pkg_name
    pm="$(get_package_manager)"
    pkg_name="$(install_catalog_pkg_name "$tool" "$pm" 2>/dev/null)" || return 1

    install_with_manager "$pkg_name"

    # Brew installs rustup-init package, initialize toolchain once.
    if [[ "$(install_catalog_normalize_tool "$tool")" == "rustup" && "$pm" == "brew" ]]; then
        command -v rustup-init >/dev/null 2>&1 && rustup-init -y
    fi
}

install_try_registry() {
    local tool
    tool="$(install_catalog_normalize_tool "$1")"

    case "$tool" in
        ruff)
            if command -v uv >/dev/null 2>&1; then
                uv tool install ruff
            elif command -v pip >/dev/null 2>&1; then
                pip install ruff
            else
                return 1
            fi
            ;;
        yazi) cargo install --locked yazi-fm yazi-cli ;;
        bottom) cargo install bottom ;;
        fnm)
            if command -v cargo >/dev/null 2>&1; then
                cargo install fnm
            else
                return 1
            fi
            ;;
        *)
            return 1
            ;;
    esac
}

install_try_release() {
    local tool
    tool="$(install_catalog_normalize_tool "$1")"

    case "$tool" in
        fzf) command -v install_fzf_by_eget >/dev/null 2>&1 && install_fzf_by_eget || install_fzf ;;
        ripgrep) command -v install_ripgrep_by_eget >/dev/null 2>&1 && install_ripgrep_by_eget || install_ripgrep ;;
        fd) command -v install_fd_by_eget >/dev/null 2>&1 && install_fd_by_eget || install_fd ;;
        bat) command -v install_bat_by_eget >/dev/null 2>&1 && install_bat_by_eget || install_bat ;;
        eza) command -v install_eza_by_eget >/dev/null 2>&1 && install_eza_by_eget || install_eza ;;
        lazygit) command -v install_lazygit_by_eget >/dev/null 2>&1 && install_lazygit_by_eget || install_lazygit ;;
        gh) command -v install_gh_by_eget >/dev/null 2>&1 && install_gh_by_eget || install_gh ;;
        zellij) command -v install_zellij_by_eget >/dev/null 2>&1 && install_zellij_by_eget || install_zellij ;;
        yazi) command -v install_yazi_by_eget >/dev/null 2>&1 && install_yazi_by_eget ;;
        bottom) command -v install_bottom_by_eget >/dev/null 2>&1 && install_bottom_by_eget ;;
        uv) curl -LsSf https://astral.sh/uv/install.sh | sh ;;
        ruff) command -v uv >/dev/null 2>&1 && uv tool install ruff ;;
        pyenv) curl https://pyenv.run | bash ;;
        rustup) curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y ;;
        fnm) curl -fsSL https://fnm.vercel.app/install | bash ;;
        *) return 1 ;;
    esac
}

install_try_source() {
    local tool
    tool="$(install_catalog_normalize_tool "$1")"
    case "$tool" in
        pyenv) install_pyenv ;;
        *) return 1 ;;
    esac
}

install_route() {
    local tool="$1"
    shift
    if [[ -z "$tool" ]]; then
        echo "Usage: install_route <tool> [--policy latest|stable] [--method auto|pkg|registry|release|source]" >&2
        return 1
    fi

    local policy="${INSTALL_POLICY:-latest}"
    local forced_method="${INSTALL_METHOD:-auto}"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --policy) policy="$2"; shift 2 ;;
            --method) forced_method="$2"; shift 2 ;;
            *) echo "Unknown option: $1" >&2; return 1 ;;
        esac
    done

    tool="$(install_catalog_normalize_tool "$tool")"
    local methods
    if [[ "$forced_method" != "auto" ]]; then
        methods="$forced_method"
    else
        methods="$(install_catalog_methods "$tool" "$policy" 2>/dev/null)" || return 1
    fi

    local method
    local -a arr
    arr=(${=methods})
    for method in "${arr[@]}"; do
        install_trace info "tool=$tool policy=$policy method=$method state=try"
        if ! install_method_available "$method" "$tool"; then
            install_trace info "tool=$tool policy=$policy method=$method state=skip reason=unavailable"
            continue
        fi

        if "install_try_${method}" "$tool"; then
            if [[ "$method" == "pkg" && "$forced_method" == "auto" ]]; then
                local binary
                binary="$(install_catalog_binary "$tool" 2>/dev/null || true)"
                if [[ -n "$binary" ]] && ! install_version_check "$tool" "$binary"; then
                    install_trace warn "tool=$tool policy=$policy method=$method state=fallback reason=version-too-old"
                    continue
                fi
            fi
            install_trace info "tool=$tool policy=$policy chosen=$method result=success"
            return 0
        fi

        install_trace warn "tool=$tool policy=$policy method=$method state=fallback reason=failed"
    done

    install_trace error "tool=$tool policy=$policy result=failed"
    return 1
}
