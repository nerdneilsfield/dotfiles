# Installer routing catalog

install_catalog_normalize_tool() {
    local tool="$1"
    case "$tool" in
        rg) echo "ripgrep" ;;
        exa) echo "eza" ;;
        btm) echo "bottom" ;;
        rust) echo "rustup" ;;
        *) echo "$tool" ;;
    esac
}

install_catalog_supported_methods() {
    local tool
    tool="$(install_catalog_normalize_tool "$1")"
    case "$tool" in
        fzf|ripgrep|fd|bat|eza|lazygit|gh|zellij|yazi|bottom)
            echo "release registry pkg source"
            ;;
        uv|ruff|fnm)
            echo "release registry pkg source"
            ;;
        pyenv|rustup)
            echo "release pkg source"
            ;;
        *)
            return 1
            ;;
    esac
}

install_catalog_methods() {
    local tool="$1"
    local policy="${2:-latest}"
    local supported
    supported="$(install_catalog_supported_methods "$tool")" || return 1

    local desired
    case "$policy" in
        stable) desired=(pkg release registry source) ;;
        *) desired=(release registry pkg source) ;;
    esac

    local available=(${=supported})
    local selected=()
    local d a
    for d in "${desired[@]}"; do
        for a in "${available[@]}"; do
            if [[ "$d" == "$a" ]]; then
                selected+=("$d")
                break
            fi
        done
    done

    echo "${selected[*]}"
}

install_catalog_binary() {
    local tool
    tool="$(install_catalog_normalize_tool "$1")"
    case "$tool" in
        fzf) echo "fzf" ;;
        ripgrep) echo "rg" ;;
        fd) echo "fd" ;;
        bat) echo "bat" ;;
        eza) echo "eza" ;;
        lazygit) echo "lazygit" ;;
        gh) echo "gh" ;;
        zellij) echo "zellij" ;;
        yazi) echo "yazi" ;;
        bottom) echo "btm" ;;
        uv) echo "uv" ;;
        ruff) echo "ruff" ;;
        pyenv) echo "pyenv" ;;
        rustup) echo "rustup" ;;
        fnm) echo "fnm" ;;
        *) return 1 ;;
    esac
}

install_catalog_min_version() {
    local tool
    tool="$(install_catalog_normalize_tool "$1")"
    case "$tool" in
        fzf) echo "0.50.0" ;;
        ripgrep) echo "14.0.0" ;;
        fd) echo "9.0.0" ;;
        bat) echo "0.24.0" ;;
        eza) echo "0.18.0" ;;
        lazygit) echo "0.41.0" ;;
        gh) echo "2.40.0" ;;
        zellij) echo "0.40.0" ;;
        yazi) echo "0.3.0" ;;
        bottom) echo "0.9.0" ;;
        uv) echo "0.4.0" ;;
        ruff) echo "0.5.0" ;;
        pyenv) echo "2.4.0" ;;
        rustup) echo "1.27.0" ;;
        fnm) echo "1.37.0" ;;
        *) return 1 ;;
    esac
}
