# kimi-code
if [[ -d "$HOME/.kimi-code/bin" ]]; then
  export PATH="$HOME/.kimi-code/bin:$PATH"
fi

# @description install openai/codex
install_codex() {
  if command -v npm &>/dev/null; then
    npm install -g @openai/codex
  else
    echo "npm is not installed"
  fi
}

_ai_install_npm_global() {
  local package_name="$1"
  local label="${2:-$1}"
  if command -v npm &>/dev/null; then
    npm install -g "$package_name"
  else
    echo "npm is not installed: cannot install ${label}"
    return 1
  fi
}

_ai_install_script() {
  local install_url="$1"
  local label="$2"
  local shell_bin="${3:-bash}"
  if command -v curl &>/dev/null; then
    curl -fsSL "$install_url" | "$shell_bin"
  else
    echo "curl is not installed: cannot install ${label}"
    return 1
  fi
}

_ai_install_uv_tool() {
  local package="$1"
  local label="${2:-$1}"
  local bin_name="${3:-$1}"
  if ! command -v uv &>/dev/null; then
    echo "uv is not installed: cannot install ${label}"
    return 1
  fi
  if command -v "$bin_name" &>/dev/null; then
    echo "${label} is already installed, upgrading"
    uv tool upgrade "${package%%\[*}" --no-cache
  else
    uv tool install "$package" --no-cache
  fi
}

# @description create runtime skills directories for AI agents
# @param $1 base_dir[optional, default: $HOME]
init_agent_skills() {
  local base_dir="${1:-$HOME}"
  local -a skill_dirs=(
    ".agent/skills"
    ".agents/skills"
    ".claude/skills"
    ".codex/skills"
    ".factory/skills"
  )
  local dir target

  base_dir="${base_dir%/}"
  if [[ -z "$base_dir" ]]; then
    base_dir="/"
  fi

  for dir in "${skill_dirs[@]}"; do
    if [[ "$base_dir" == "/" ]]; then
      target="/${dir}"
    else
      target="${base_dir}/${dir}"
    fi

    if [[ -d "$target" ]]; then
      print -r -- "exists: ${target}"
    else
      mkdir -p "$target" || return 1
      print -r -- "created: ${target}"
    fi
  done
}

init_agents_dir() {
  init_agent_skills "$@"
}

# @description initialize runtime skills dirs and stow shared agent skills
# @param $1 dotfiles_dir[optional, default: $DOTFILES_DIR or $HOME/Source/configs/dotfiles]
stow_agents_skills() {
  local dotfiles_dir="${1:-${DOTFILES_DIR:-$HOME/Source/configs/dotfiles}}"
  local expected_remote_slug="${DOTFILES_REMOTE_SLUG:-nerdneilsfield/dotfiles}"
  local remote_url remote_slug

  if ! command -v stow &>/dev/null; then
    echo "stow is not installed"
    return 1
  fi

  if [[ ! -d "$dotfiles_dir" ]]; then
    echo "dotfiles directory does not exist: ${dotfiles_dir}" >&2
    return 1
  fi

  (
    builtin cd "$dotfiles_dir" || return 1
    if ! remote_url="$(git remote get-url origin 2>/dev/null)"; then
      echo "not a git repository with origin remote: ${dotfiles_dir}" >&2
      return 1
    fi
    remote_slug="${remote_url%.git}"
    remote_slug="${remote_slug#git@github.com:}"
    remote_slug="${remote_slug#https://github.com/}"
    remote_slug="${remote_slug#http://github.com/}"
    if [[ "$remote_slug" != "$expected_remote_slug" ]]; then
      echo "unexpected dotfiles remote: ${remote_url}" >&2
      echo "expected GitHub repo: ${expected_remote_slug}" >&2
      return 1
    fi

    init_agent_skills "$HOME" || return 1

    if [[ ! -d agents || ! -d factory ]]; then
      echo "agents and factory stow packages must exist in ${dotfiles_dir}" >&2
      return 1
    fi
    stow -Rvt "$HOME" agents factory
  )
}

install_kimi_cli() {
  if command -v uv &>/dev/null; then
    if command -v kimi &>/dev/null; then
      echo "kimi is already installed, upgrading"
      uv tool upgrade kimi-cli --no-cache
    else
      uv tool install kimi-cli --no-cache
    fi
  else
    echo "uv is not installed"
  fi
}

# @description install kimi code
install_kimi_code() {
  _ai_install_script "https://code.kimi.com/kimi-code/install.sh" "Kimi Code"
}

# @description install mimo code
install_mimo_code() {
  _ai_install_script "https://mimo.xiaomi.com/install" "Mimo Code"
}

# @description install anthropic/codex
install_claude_code() {
  if command -v npm &>/dev/null; then
    npm install -g @anthropic-ai/claude-code
  else
    echo "npm is not installed"
  fi
}

# @description install anthropic/codex
install_kilo_cli() {
  if command -v npm &>/dev/null; then
    npm install -g @kilocode/cli
  else
    echo "npm is not installed"
  fi
}

# @description install pi-coding-agent
install_pi_agent() {
  if command -v npm &>/dev/null; then
    npm install -g @mariozechner/pi-coding-agent
  else
    echo "npm is not installed"
  fi

}

install_gemini_cli() {
  _ai_install_npm_global "@google/gemini-cli" "Gemini CLI"
}

install_qwen_code() {
  _ai_install_npm_global "@qwen-code/qwen-code" "Qwen Code"
}

# @description install openspec cli
install_openspec_cli() {
  _ai_install_npm_global "@fission-ai/openspec" "OpenSpec CLI"
}

# @description install factory droid cli
install_factory_droid() {
  _ai_install_script "https://app.factory.ai/cli" "Factory Droid CLI"
}

# @description install goose cli
install_goose_cli() {
  if command -v brew &>/dev/null; then
    brew install --cask block-goose
  else
    echo "Homebrew is not installed; please install Goose from https://block.github.io/goose/docs/getting-started/installation/"
    return 1
  fi
}

# @description install opencode cli
install_opencode_cli() {
  if command -v npm &>/dev/null; then
    # official package name is `opencode`
    _ai_install_npm_global "${OPENCODE_CLI_NPM_PACKAGE:-opencode}" "OpenCode CLI"
  else
    _ai_install_script "https://opencode.ai/install" "OpenCode CLI"
  fi
}

_ai_install_or_upgrade_crush_by_brew() {
  local formula="${CRUSH_CLI_BREW_FORMULA:-charmbracelet/tap/crush}"

  if command -v crush &>/dev/null; then
    echo "crush is already installed, upgrading via Homebrew"
    brew upgrade "$formula" || brew install "$formula"
  else
    echo "Installing crush via Homebrew"
    brew install "$formula"
  fi
}

_ai_install_or_upgrade_crush_by_yay() {
  local package="${CRUSH_CLI_YAY_PACKAGE:-crush-bin}"

  if command -v crush &>/dev/null; then
    echo "crush is already installed, upgrading via yay"
  else
    echo "Installing crush via yay"
  fi

  yay -S --needed "$package"
}

_ai_install_or_upgrade_crush_by_nix() {
  local installable="${CRUSH_CLI_NIX_INSTALLABLE:-github:numtide/nix-ai-tools#crush}"
  local fallback_installable="${CRUSH_CLI_NIX_FALLBACK_INSTALLABLE:-nixpkgs#crush}"

  if command -v crush &>/dev/null; then
    echo "crush is already installed, upgrading via nix profile"
    nix profile upgrade crush ||
      nix profile upgrade --regex '.*crush.*' ||
      nix profile install "$installable" ||
      nix profile install "$fallback_installable"
  else
    echo "Installing crush via nix profile"
    nix profile install "$installable" || nix profile install "$fallback_installable"
  fi
}

_ai_install_or_upgrade_crush_by_eget() {
  local repo="${CRUSH_CLI_EGET_REPO:-charmbracelet/crush}"
  local install_prefix="${CRUSH_CLI_EGET_PREFIX:-local}"
  local eget_bin

  if ! command -v eget &>/dev/null; then
    echo "eget is not installed: cannot install crush from ${repo}" >&2
    return 1
  fi

  if command -v crush &>/dev/null; then
    echo "crush is already installed, upgrading via eget"
  else
    echo "Installing crush via eget"
  fi

  if command -v _install_tool_by_eget &>/dev/null; then
    _install_tool_by_eget "$repo" "$install_prefix"
    return $?
  fi

  case "$install_prefix" in
    global) eget_bin="/usr/local/bin" ;;
    local) eget_bin="$HOME/.local/bin" ;;
    *) eget_bin="${install_prefix}/bin" ;;
  esac

  mkdir -p "$eget_bin" || return 1
  EGET_BIN="$eget_bin" eget "$repo"
}

# @description install crush cli
install_crush_cli() {
  if command -v brew &>/dev/null; then
    _ai_install_or_upgrade_crush_by_brew
  elif command -v yay &>/dev/null; then
    _ai_install_or_upgrade_crush_by_yay
  elif command -v nix &>/dev/null; then
    _ai_install_or_upgrade_crush_by_nix
  else
    _ai_install_or_upgrade_crush_by_eget
  fi
}

# @description install cursor cli
install_cursor_cli() {
  _ai_install_script "https://cursor.com/install" "Cursor CLI"
}

# @description install grok cli
install_grok_cli() {
  _ai_install_script "https://x.ai/cli/install.sh" "Grok CLI"
}

# @description install headroom-ai (uv tool)
install_headroom_ai() {
  _ai_install_uv_tool "headroom-ai[all]" "Headroom AI" "headroom"
}

# @description install rtk cli
install_rtk_cli() {
  if command -v brew &>/dev/null; then
    if command -v rtk &>/dev/null; then
      echo "rtk is already installed, upgrading via Homebrew"
      brew upgrade rtk || brew install rtk
    else
      brew install rtk
    fi
  else
    _ai_install_script \
      "https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh" \
      "RTK CLI" \
      "sh"
  fi
}

# @description install caveman cli
install_caveman_cli() {
  _ai_install_script \
    "https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh" \
    "Caveman CLI"
}

# @description install headroom-ai, rtk, and caveman in one go
install_extra_ai_tools() {
  install_headroom_ai || true
  install_rtk_cli || true
  install_caveman_cli || true
}

update_ai_tools() {
  if command -v npm &>/dev/null; then
    npm update -g @openai/codex
    npm update -g @anthropic-ai/claude-code
    npm update -g @google/gemini-cli
    npm update -g @kilocode/cli || true
    npm update -g @qwen-code/qwen-code
    npm update -g @mariozechner/pi-coding-agent || true
    npm update -g "${OPENCODE_CLI_NPM_PACKAGE:-opencode}" || true
    npm update -g @fission-ai/openspec || true
  else
    echo "npm is not installed; skipping npm-based AI tools"
  fi

  command -v crush &>/dev/null && install_crush_cli || true

  command -v cursor-agent &>/dev/null && cursor-agent update || true
  command -v opencode &>/dev/null && opencode upgrade || true
  command -v goose &>/dev/null && goose --version >/dev/null || true
  command -v grok &>/dev/null && install_grok_cli || true
}

reinstall_ai_tools() {
  if command -v npm &>/dev/null; then
    npm uninstall -g @openai/codex @anthropic-ai/claude-code @google/gemini-cli @kilocode/cli @qwen-code/qwen-code @mariozechner/pi-coding-agent opencode @fission-ai/openspec
  else
    echo "npm is not installed; skipping npm-based AI tools reinstall"
  fi

  command -v crush &>/dev/null && install_crush_cli || true
  update_ai_tools
}

# @description install aichat
# @param $1 install_prefix[optional, default: $HOME/.local]
# @return 0 on success
# @example install_aichat
# @category ai
install_aichat() {
  local install_prefix="$HOME/.local"
  # if have $1, use $1 as install_prefix
  if [ -n "$1" ]; then
    install_prefix="$1"
  fi
  local ai_chat_url="https://github.com/sigoden/aichat/releases/download/v0.29.0/aichat-v0.29.0-x86_64-unknown-linux-musl.tar.gz"

  if command -v batch_smart_download_tools >/dev/null 2>&1; then
    echo "🚀 智能安装 aichat..."
    mkdir -p "$install_prefix"
    batch_smart_download_tools "$ai_chat_url" "$install_prefix"
    return $?
  else
    echo "⚠️ 核心函数 batch_smart_download_tools 未找到。请确保 utils.zsh 已正确加载。" >&2
    echo "   尝试使用旧方法回退安装 aichat... (可能已移除)" >&2
    return 1
  fi
}

_mcp_require_jq() {
  if ! command -v jq &>/dev/null; then
    echo "jq is required for MCP conversion. Install it first (e.g. brew install jq)." >&2
    return 1
  fi
}

_mcp_require_json_source() {
  local src="$1"
  if ! jq empty "$src" >/dev/null 2>&1; then
    echo "Source must be JSON. For TOML input, use mcp_generate_add_commands (it auto-converts)." >&2
    return 1
  fi
}

_mcp_prepare_source_json() {
  local src="$1"
  if jq empty "$src" >/dev/null 2>&1; then
    echo "$src"
    return 0
  fi

  if [[ "$src" == *.toml ]]; then
    local tmpfile
    tmpfile="$(mktemp /tmp/mcp-from-toml.XXXXXX)"
    local converted_by_taplo=0

    # Prefer taplo for TOML parsing if available.
    if command -v taplo &>/dev/null; then
      if taplo format --output-format json "$src" >"$tmpfile" 2>/dev/null; then
        if jq empty "$tmpfile" >/dev/null 2>&1; then
          converted_by_taplo=1
        fi
      fi
    fi

    if [[ "$converted_by_taplo" -eq 1 ]]; then
      echo "$tmpfile"
      return 0
    fi

    # Fallback to Python stdlib TOML parser.
    if ! command -v python3 &>/dev/null; then
      rm -f "$tmpfile"
      echo "TOML source detected: $src" >&2
      echo "Install taplo (recommended): install_taplo_by_brew or install_taplo_by_eget" >&2
      echo "Or install python3 to enable fallback TOML parsing." >&2
      return 1
    fi
    if ! python3 - "$src" "$tmpfile" <<'PY'; then
import json
import sys
import tomllib

src = sys.argv[1]
dst = sys.argv[2]

with open(src, "rb") as f:
    data = tomllib.load(f)

mcp_servers = data.get("mcp_servers", {})
out = {"mcpServers": {}}

for name, cfg in mcp_servers.items():
    if not isinstance(cfg, dict):
        continue
    entry = {}
    if isinstance(cfg.get("url"), str):
        entry["url"] = cfg["url"]
    if isinstance(cfg.get("http_headers"), dict):
        entry["headers"] = cfg["http_headers"]
    if isinstance(cfg.get("command"), str):
        entry["command"] = cfg["command"]
    if isinstance(cfg.get("args"), list):
        entry["args"] = cfg["args"]
    if isinstance(cfg.get("env"), dict):
        entry["env"] = cfg["env"]
    if cfg.get("enabled") is False:
        entry["disabled"] = True
    out["mcpServers"][name] = entry

with open(dst, "w", encoding="utf-8") as f:
    json.dump(out, f, ensure_ascii=False)
PY
      rm -f "$tmpfile"
      echo "Failed to parse TOML source: $src" >&2
      echo "Install taplo (recommended): install_taplo_by_brew or install_taplo_by_eget" >&2
      return 1
    fi
    echo "$tmpfile"
    return 0
  fi

  echo "Unsupported source format: $src (need JSON or TOML)" >&2
  return 1
}

_mcp_detect_source_type() {
  local src="$1"
  jq -r '
    if (."$schema"? == "https://charm.land/crush.json") then
      "crush"
    elif (.mcpServers? and ((.mcpServers|type) == "object")) then
      "mcpservers_json"
    elif (.mcp? and ((.mcp|type) == "object")) then
      if ([.mcp[]? | .type?] | any(. == "stdio" or . == "http" or . == "sse")) then
        "crush"
      else
        "opencode"
      end
    else
      "unknown"
    end
  ' "$src" 2>/dev/null
}

_mcp_extract_servers() {
  local src="$1"
  jq '
    if (.mcpServers? and ((.mcpServers|type) == "object")) then
      .mcpServers
      | with_entries(
          .value = (
            if (.value.httpUrl? and ((.value.httpUrl|type) == "string")) then
              {
                type: "http",
                url: .value.httpUrl
              }
              + (if .value.headers? then {headers: .value.headers} else {} end)
              + (if .value.env? then {env: .value.env} else {} end)
              + (if .value.timeout? then {timeout: .value.timeout} else {} end)
              + (if .value.trust? then {trust: .value.trust} else {} end)
              + (if .value.disabled? then {disabled: .value.disabled} else {} end)
            elif (.value.url? and ((.value.url|type) == "string")) then
              {
                url: .value.url
              }
              + (if .value.type? then {type: .value.type} else {} end)
              + (if .value.headers? then {headers: .value.headers} else {} end)
              + (if .value.env? then {env: .value.env} else {} end)
              + (if .value.timeout? then {timeout: .value.timeout} else {} end)
              + (if .value.trust? then {trust: .value.trust} else {} end)
              + (if .value.disabled_tools? then {disabled_tools: .value.disabled_tools} else {} end)
              + (if .value.disabled? then {disabled: .value.disabled} else {} end)
            elif (.value.command? and ((.value.command|type) == "string")) then
              {
                command: .value.command
              }
              + (if .value.args? then {args: .value.args} else {} end)
              + (if .value.env? then {env: .value.env} else {} end)
              + (if .value.timeout? then {timeout: .value.timeout} else {} end)
              + (if .value.trust? then {trust: .value.trust} else {} end)
              + (if .value.disabled_tools? then {disabled_tools: .value.disabled_tools} else {} end)
              + (if .value.disabled? then {disabled: .value.disabled} else {} end)
            else
              .value
            end
          )
        )
    elif (.mcp? and ((.mcp|type) == "object")) then
      .mcp
      | with_entries(
          .value = (
            if (.value.type? == "remote" or (.value.url? and ((.value.url|type) == "string"))) then
              {
                url: .value.url
              }
              + (if .value.headers? then {headers: .value.headers} else {} end)
              + (if .value.environment? then {env: .value.environment} else {} end)
              + (if .value.timeout? then {timeout: .value.timeout} else {} end)
              + (if .value.disabled_tools? then {disabled_tools: .value.disabled_tools} else {} end)
              + (if .value.enabled == false then {disabled: true} else {} end)
            elif (.value.type? == "local" or .value.command?) then
              (
                if ((.value.command|type) == "array") then
                  {
                    command: (.value.command[0] // ""),
                    args: (.value.command[1:] // [])
                  }
                elif ((.value.command|type) == "string") then
                  {
                    command: .value.command,
                    args: (.value.args // [])
                  }
                else
                  {}
                end
              )
              + (if .value.environment? then {env: .value.environment} else {} end)
              + (if .value.timeout? then {timeout: .value.timeout} else {} end)
              + (if .value.disabled_tools? then {disabled_tools: .value.disabled_tools} else {} end)
              + (if .value.enabled == false then {disabled: true} else {} end)
            else
              .value
            end
          )
        )
    else
      {}
    end
  ' "$src"
}

_mcp_emit_factory_json() {
  local src="$1"
  _mcp_extract_servers "$src" | jq '
    {
      mcpServers: (
        with_entries(
          .value = (
            if (.value.url? and ((.value.url|type) == "string")) then
              {
                type: "http",
                url: .value.url
              }
              + (if .value.headers? then {headers: .value.headers} else {} end)
              + (if .value.env? then {env: .value.env} else {} end)
              + (if .value.disabled? then {disabled: .value.disabled} else {} end)
            elif (.value.command? and ((.value.command|type) == "string")) then
              {
                type: "stdio",
                command: .value.command
              }
              + (if .value.args? then {args: .value.args} else {} end)
              + (if .value.env? then {env: .value.env} else {} end)
              + (if .value.disabled? then {disabled: .value.disabled} else {} end)
            else
              .value
            end
          )
        )
      )
    }
  '
}

_mcp_emit_cursor_json() {
  local src="$1"
  _mcp_extract_servers "$src" | jq '
    {
      mcpServers: (
        with_entries(
          .value = (
            if (.value.url? and ((.value.url|type) == "string")) then
              {
                url: .value.url
              }
              + (if .value.headers? then {headers: .value.headers} else {} end)
              + (if .value.env? then {env: .value.env} else {} end)
              + (if .value.disabled? then {disabled: .value.disabled} else {} end)
            elif (.value.command? and ((.value.command|type) == "string")) then
              {
                command: .value.command
              }
              + (if .value.args? then {args: .value.args} else {} end)
              + (if .value.env? then {env: .value.env} else {} end)
              + (if .value.disabled? then {disabled: .value.disabled} else {} end)
            else
              .value
            end
          )
        )
      )
    }
  '
}

_mcp_emit_claude_json() {
  local src="$1"
  _mcp_extract_servers "$src" | jq '
    {
      mcpServers: (
        with_entries(
          .value = (
            if (.value.url? and ((.value.url|type) == "string")) then
              {
                type: (
                  if .value.type == "sse" then "sse"
                  elif .value.type == "http" then "http"
                  else "http"
                  end
                ),
                url: .value.url
              }
              + (if .value.headers? then {headers: .value.headers} else {} end)
              + (if .value.env? then {env: .value.env} else {} end)
              + (if .value.disabled? then {disabled: .value.disabled} else {} end)
            elif (.value.command? and ((.value.command|type) == "string")) then
              {
                type: "stdio",
                command: .value.command
              }
              + (if .value.args? then {args: .value.args} else {} end)
              + (if .value.env? then {env: .value.env} else {} end)
              + (if .value.disabled? then {disabled: .value.disabled} else {} end)
            else
              .value
            end
          )
        )
      )
    }
  '
}

_mcp_emit_kimi_json() {
  local src="$1"
  _mcp_emit_cursor_json "$src"
}

_mcp_emit_gemini_json() {
  local src="$1"
  _mcp_extract_servers "$src" | jq '
    {
      mcpServers: (
        with_entries(
          .value = (
            if (.value.url? and ((.value.url|type) == "string")) then
              (
                if .value.type == "sse" then
                  {url: .value.url}
                else
                  {httpUrl: .value.url}
                end
              )
              + (if .value.headers? then {headers: .value.headers} else {} end)
              + (if .value.timeout? then {timeout: .value.timeout} else {} end)
              + (if .value.trust? then {trust: .value.trust} else {} end)
              + (if .value.disabled? then {disabled: .value.disabled} else {} end)
            elif (.value.command? and ((.value.command|type) == "string")) then
              {
                command: .value.command
              }
              + (if .value.args? then {args: .value.args} else {} end)
              + (if .value.env? then {env: .value.env} else {} end)
              + (if .value.timeout? then {timeout: .value.timeout} else {} end)
              + (if .value.trust? then {trust: .value.trust} else {} end)
              + (if .value.disabled? then {disabled: .value.disabled} else {} end)
            else
              .value
            end
          )
        )
      )
    }
  '
}

_mcp_emit_codex_toml() {
  local src="$1"
  _mcp_extract_servers "$src" | jq -r '
    to_entries[]
    | .key as $name
    | if (.value.command? and ((.value.command|type) == "string")) then
        "[mcp_servers." + $name + "]\n"
        + "command = " + (.value.command|@json) + "\n"
        + (if (.value.args? and ((.value.args|type) == "array") and (.value.args|length>0))
            then "args = " + (.value.args|@json) + "\n"
            else "" end)
        + (if (.value.disabled? and .value.disabled == true)
            then "enabled = false\n"
            else "" end)
        + (if (.value.env? and ((.value.env|type) == "object") and ((.value.env|keys|length)>0))
            then "[mcp_servers." + $name + ".env]\n"
              + (.value.env|to_entries|map(.key + " = " + (.value|@json))|join("\n"))
              + "\n"
            else "" end)
        + "\n"
      elif (.value.url? and ((.value.url|type) == "string")) then
        "[mcp_servers." + $name + "]\n"
        + "url = " + (.value.url|@json) + "\n"
        + (if (.value.disabled? and .value.disabled == true)
            then "enabled = false\n"
            else "" end)
        + (if (.value.headers? and ((.value.headers|type) == "object") and ((.value.headers|keys|length)>0))
            then "http_headers = { "
              + (.value.headers|to_entries|map(.key + " = " + (.value|@json))|join(", "))
              + " }\n"
            else "" end)
        + "\n"
      else
        ""
      end
  '
}

_mcp_emit_opencode_json() {
  local src="$1"
  _mcp_extract_servers "$src" | jq '
    {
      "$schema": "https://opencode.ai/config.json",
      mcp: (
        with_entries(
          .value = (
            if (.value.url? and ((.value.url|type) == "string")) then
              {
                type: "remote",
                url: .value.url
              }
              + (if .value.headers? then {headers: .value.headers} else {} end)
              + (if .value.env? then {environment: .value.env} else {} end)
            elif (.value.command? and ((.value.command|type) == "string")) then
              {
                type: "local",
                command: ([.value.command] + (.value.args // []))
              }
              + (if .value.env? then {environment: .value.env} else {} end)
            else
              .value
            end
            + {enabled: (if .value.disabled == true then false else true end)}
          )
        )
      )
    }
  '
}

_mcp_emit_kilo_json() {
  local src="$1"
  _mcp_extract_servers "$src" | jq '
    {
      "$schema": "https://kilo.ai/config.json",
      mcp: (
        with_entries(
          .value = (
            if (.value.url? and ((.value.url|type) == "string")) then
              {
                type: "remote",
                url: .value.url
              }
              + (if .value.headers? then {headers: .value.headers} else {} end)
              + (if .value.env? then {environment: .value.env} else {} end)
              + (if .value.timeout? then {timeout: .value.timeout} else {} end)
            elif (.value.command? and ((.value.command|type) == "string")) then
              {
                type: "local",
                command: ([.value.command] + (.value.args // []))
              }
              + (if .value.env? then {environment: .value.env} else {} end)
              + (if .value.timeout? then {timeout: .value.timeout} else {} end)
            else
              .value
            end
            + {enabled: (if .value.disabled == true then false else true end)}
          )
        )
      )
    }
  '
}

_mcp_emit_crush_json() {
  local src="$1"
  _mcp_extract_servers "$src" | jq '
    {
      "$schema": "https://charm.land/crush.json",
      mcp: (
        with_entries(
          .value = (
            if (.value.url? and ((.value.url|type) == "string")) then
              {
                type: (
                  if .value.type == "sse" then "sse"
                  else "http"
                  end
                ),
                url: .value.url
              }
              + (if .value.headers? then {headers: .value.headers} else {} end)
              + (if .value.env? then {env: .value.env} else {} end)
              + (if .value.timeout? then {timeout: .value.timeout} else {} end)
              + (if .value.disabled_tools? then {disabled_tools: .value.disabled_tools} else {} end)
            elif (.value.command? and ((.value.command|type) == "string")) then
              {
                type: "stdio",
                command: .value.command
              }
              + (if .value.args? then {args: .value.args} else {} end)
              + (if .value.env? then {env: .value.env} else {} end)
              + (if .value.timeout? then {timeout: .value.timeout} else {} end)
              + (if .value.disabled_tools? then {disabled_tools: .value.disabled_tools} else {} end)
            else
              .value
            end
            + {disabled: (if .value.disabled == true then true else false end)}
          )
        )
      )
    }
  '
}

# @description convert MCP config to Factory MCP config (source can be JSON with mcpServers/mcp)
# @param $1 source mcp json (optional)
# @param $2 target factory mcp json (optional, default: ~/.factory/mcp.json)
# @example mcp_convert_cursor_to_factory
# @category ai
mcp_convert_cursor_to_factory() {
  _mcp_require_jq || return 1

  local src
  src="$(_mcp_detect_source_file "$1")"
  local dst="${2:-$HOME/.factory/mcp.json}"

  if [[ -z "$src" || ! -f "$src" ]]; then
    echo "MCP config not found. Pass a file path or use mcp_convert_interactive." >&2
    return 1
  fi
  _mcp_require_json_source "$src" || return 1

  mkdir -p "$(dirname "$dst")"
  _mcp_emit_factory_json "$src" >"$dst"
  echo "converted MCP ($(_mcp_detect_source_type "$src")) -> Factory MCP: $dst"
}

# @description convert MCP config to OpenCode MCP config (source can be JSON with mcpServers/mcp)
# @param $1 source mcp json (optional)
# @param $2 target opencode config json (optional, default: ~/.config/opencode/opencode.json)
# @example mcp_convert_cursor_to_opencode
# @category ai
mcp_convert_cursor_to_opencode() {
  _mcp_require_jq || return 1

  local src
  src="$(_mcp_detect_source_file "$1")"
  local dst="${2:-$HOME/.config/opencode/opencode.json}"

  if [[ -z "$src" || ! -f "$src" ]]; then
    echo "MCP config not found. Pass a file path or use mcp_convert_interactive." >&2
    return 1
  fi
  _mcp_require_json_source "$src" || return 1

  mkdir -p "$(dirname "$dst")"
  _mcp_emit_opencode_json "$src" >"$dst"
  echo "converted MCP ($(_mcp_detect_source_type "$src")) -> OpenCode MCP: $dst"
}

# @description convert MCP config to Kilo MCP config (source can be JSON with mcpServers/mcp)
# @param $1 source mcp json (optional)
# @param $2 target kilo config json (optional, default: ~/.config/kilo/kilo.json)
# @example mcp_convert_cursor_to_kilo
# @category ai
mcp_convert_cursor_to_kilo() {
  _mcp_require_jq || return 1

  local src
  src="$(_mcp_detect_source_file "$1")"
  local dst="${2:-$HOME/.config/kilo/kilo.json}"

  if [[ -z "$src" || ! -f "$src" ]]; then
    echo "MCP config not found. Pass a file path or use mcp_convert_interactive." >&2
    return 1
  fi
  _mcp_require_json_source "$src" || return 1

  mkdir -p "$(dirname "$dst")"
  _mcp_emit_kilo_json "$src" >"$dst"
  echo "converted MCP ($(_mcp_detect_source_type "$src")) -> Kilo MCP: $dst"
}

# @description print Goose extension conversion hints from MCP config (source can be JSON with mcpServers/mcp)
# @param $1 source mcp json (optional)
# @example mcp_convert_cursor_to_goose
# @category ai
mcp_convert_cursor_to_goose() {
  _mcp_require_jq || return 1

  local src
  src="$(_mcp_detect_source_file "$1")"

  if [[ -z "$src" || ! -f "$src" ]]; then
    echo "MCP config not found. Pass a file path or use mcp_convert_interactive." >&2
    return 1
  fi
  _mcp_require_json_source "$src" || return 1

  echo "Goose conversion guide (from $src, detected: $(_mcp_detect_source_type "$src")):"
  echo "1) run: goose configure"
  echo "2) choose: Add Extension -> Command-line Extension (for stdio) or URL/SSE style (for remote)"
  echo "3) map each server as below:"
  _mcp_extract_servers "$src" | jq -r '
    to_entries[]
    | if (.value.url? and ((.value.url|type) == "string")) then
        "- " + .key + " => remote endpoint: " + .value.url
      elif (.value.command? and ((.value.command|type) == "string")) then
        "- " + .key + " => command: " + ([.value.command] + (.value.args // []) | join(" "))
      else
        "- " + .key + " => unsupported schema, configure manually"
      end
  '
  echo "Goose config file reference: ~/.config/goose/config.yaml"
}

# @description convert MCP config to Crush MCP config (source can be JSON with mcpServers/mcp)
# @param $1 source mcp json (optional)
# @param $2 target crush config json (optional, default: ~/.config/crush/crush.json)
# @example mcp_convert_cursor_to_crush
# @category ai
mcp_convert_cursor_to_crush() {
  _mcp_require_jq || return 1

  local src
  src="$(_mcp_detect_source_file "$1")"
  local dst="${2:-$HOME/.config/crush/crush.json}"

  if [[ -z "$src" || ! -f "$src" ]]; then
    echo "MCP config not found. Pass a file path or use mcp_convert_interactive." >&2
    return 1
  fi
  _mcp_require_json_source "$src" || return 1

  mkdir -p "$(dirname "$dst")"
  _mcp_emit_crush_json "$src" >"$dst"
  echo "converted MCP ($(_mcp_detect_source_type "$src")) -> Crush MCP: $dst"
}

# @description convert Cursor MCP config to Factory + OpenCode + Crush and print Goose hints
# @param $1 source cursor mcp json (optional)
# @example mcp_convert_cursor_all
# @category ai
mcp_convert_cursor_all() {
  local src="$1"
  mcp_convert_cursor_to_factory "$src" || return 1
  mcp_convert_cursor_to_opencode "$src" || return 1
  mcp_convert_cursor_to_kilo "$src" || return 1
  mcp_convert_cursor_to_crush "$src" || return 1
  mcp_convert_cursor_to_goose "$src" || return 1
}

_mcp_write_gemini_settings() {
  local src="$1"
  local dst="${2:-$HOME/.gemini/settings.json}"
  local tmpfile
  tmpfile="$(mktemp /tmp/mcp-gemini.XXXXXX)"
  _mcp_emit_gemini_json "$src" >"$tmpfile"
  mkdir -p "$(dirname "$dst")"

  if [[ -f "$dst" ]]; then
    jq --slurpfile m "$tmpfile" '.mcpServers = (.mcpServers // {}) + ($m[0].mcpServers // {})' "$dst" >"${dst}.tmp" &&
      mv "${dst}.tmp" "$dst"
  else
    echo '{ "mcpServers": {} }' | jq --slurpfile m "$tmpfile" '.mcpServers = ($m[0].mcpServers // {})' >"$dst"
  fi
  rm -f "$tmpfile"
  echo "converted MCP ($(_mcp_detect_source_type "$src")) -> Gemini settings: $dst"
}

_mcp_write_codex_config() {
  local src="$1"
  local dst="${2:-$HOME/.codex/config.toml}"
  local generated="${HOME}/.codex/mcp.generated.toml"
  mkdir -p "$HOME/.codex"
  _mcp_emit_codex_toml "$src" >"$generated"
  if [[ ! -f "$dst" ]]; then
    cp "$generated" "$dst"
    echo "created Codex config: $dst"
  else
    echo "existing Codex config detected: $dst"
    echo "generated MCP snippet: $generated"
    echo "please merge snippet into $dst to avoid overwriting unrelated settings."
  fi
}

_mcp_detect_source_file() {
  local src="$1"
  if [[ -n "$src" && -f "$src" ]]; then
    echo "$src"
    return 0
  fi
  if [[ -f ".cursor/mcp.json" ]]; then
    echo ".cursor/mcp.json"
    return 0
  fi
  if [[ -f "$HOME/.cursor/mcp.json" ]]; then
    echo "$HOME/.cursor/mcp.json"
    return 0
  fi
  if [[ -f ".factory/mcp.json" ]]; then
    echo ".factory/mcp.json"
    return 0
  fi
  if [[ -f "$HOME/.factory/mcp.json" ]]; then
    echo "$HOME/.factory/mcp.json"
    return 0
  fi
  if [[ -f ".config/opencode/opencode.json" ]]; then
    echo ".config/opencode/opencode.json"
    return 0
  fi
  if [[ -f "opencode.json" ]]; then
    echo "opencode.json"
    return 0
  fi
  if [[ -f "$HOME/.config/opencode/opencode.json" ]]; then
    echo "$HOME/.config/opencode/opencode.json"
    return 0
  fi
  if [[ -f ".kilo/kilo.json" ]]; then
    echo ".kilo/kilo.json"
    return 0
  fi
  if [[ -f "kilo.json" ]]; then
    echo "kilo.json"
    return 0
  fi
  if [[ -f "$HOME/.config/kilo/kilo.json" ]]; then
    echo "$HOME/.config/kilo/kilo.json"
    return 0
  fi
  if [[ -f "$HOME/.config/kilo/opencode.json" ]]; then
    echo "$HOME/.config/kilo/opencode.json"
    return 0
  fi
  if [[ -f ".crush.json" ]]; then
    echo ".crush.json"
    return 0
  fi
  if [[ -f "crush.json" ]]; then
    echo "crush.json"
    return 0
  fi
  if [[ -f "$HOME/.config/crush/crush.json" ]]; then
    echo "$HOME/.config/crush/crush.json"
    return 0
  fi
  if [[ -f ".mcp.json" ]]; then
    echo ".mcp.json"
    return 0
  fi
  if [[ -f "$HOME/.kimi/mcp.json" ]]; then
    echo "$HOME/.kimi/mcp.json"
    return 0
  fi
  if [[ -f ".gemini/settings.json" ]]; then
    echo ".gemini/settings.json"
    return 0
  fi
  if [[ -f "$HOME/.gemini/settings.json" ]]; then
    echo "$HOME/.gemini/settings.json"
    return 0
  fi
  return 1
}

_mcp_read_json_interactive() {
  local source_file
  source_file="$(_mcp_detect_source_file "$1")"

  echo "MCP source input:"
  echo "1) Use existing MCP config (${source_file:-not found})"
  echo "2) Paste JSON manually (end with Ctrl-D)"
  printf "Choose [1/2]: "
  local choice
  read -r choice

  if [[ "$choice" == "2" ]]; then
    local tmpfile
    tmpfile="$(mktemp /tmp/mcp-input.XXXXXX)"
    cat >"$tmpfile"
    if ! jq empty "$tmpfile" >/dev/null 2>&1; then
      echo "Invalid JSON input." >&2
      rm -f "$tmpfile"
      return 1
    fi
    echo "$tmpfile"
    return 0
  fi

  if [[ -n "$source_file" ]]; then
    echo "$source_file"
    return 0
  fi

  echo "No MCP file found. Please choose option 2 and paste JSON." >&2
  return 1
}

# @description interactive MCP converter (source can be JSON with mcpServers/mcp)
# @param $1 source mcp json path (optional)
# @example mcp_convert_interactive
# @category ai
mcp_convert_interactive() {
  _mcp_require_jq || return 1

  local src
  src="$(_mcp_read_json_interactive "$1")" || return 1
  _mcp_require_json_source "$src" || return 1
  local cleanup_tmp=0
  [[ "$src" == /tmp/mcp-input.*.json ]] && cleanup_tmp=1

  echo "Detected source type: $(_mcp_detect_source_type "$src")"
  echo
  echo "Target platform:"
  echo "1) Factory"
  echo "2) OpenCode"
  echo "3) Kilo"
  echo "4) Crush"
  echo "5) Goose (mapping hints)"
  echo "6) Cursor"
  echo "7) Claude Code"
  echo "8) Gemini CLI"
  echo "9) Kimi CLI"
  echo "10) Codex CLI"
  echo "11) All"
  printf "Choose [1/2/3/4/5/6/7/8/9/10/11]: "
  local target
  read -r target

  echo
  echo "Output mode:"
  echo "1) Print to terminal (copy manually)"
  echo "2) Write to default target file(s)"
  printf "Choose [1/2]: "
  local mode
  read -r mode

  case "$target" in
  1)
    if [[ "$mode" == "2" ]]; then
      mcp_convert_cursor_to_factory "$src"
    else
      _mcp_emit_factory_json "$src"
    fi
    ;;
  2)
    if [[ "$mode" == "2" ]]; then
      mcp_convert_cursor_to_opencode "$src"
    else
      _mcp_emit_opencode_json "$src"
    fi
    ;;
  3)
    if [[ "$mode" == "2" ]]; then
      mcp_convert_cursor_to_kilo "$src"
    else
      _mcp_emit_kilo_json "$src"
    fi
    ;;
  4)
    if [[ "$mode" == "2" ]]; then
      mcp_convert_cursor_to_crush "$src"
    else
      _mcp_emit_crush_json "$src"
    fi
    ;;
  5)
    mcp_convert_cursor_to_goose "$src"
    ;;
  6)
    if [[ "$mode" == "2" ]]; then
      local cursor_dst="$HOME/.cursor/mcp.json"
      mkdir -p "$(dirname "$cursor_dst")"
      _mcp_emit_cursor_json "$src" >"$cursor_dst"
      echo "converted MCP ($(_mcp_detect_source_type "$src")) -> Cursor MCP: $cursor_dst"
    else
      _mcp_emit_cursor_json "$src"
    fi
    ;;
  7)
    if [[ "$mode" == "2" ]]; then
      local claude_dst=".mcp.json"
      _mcp_emit_claude_json "$src" >"$claude_dst"
      echo "converted MCP ($(_mcp_detect_source_type "$src")) -> Claude Code MCP: $claude_dst"
    else
      _mcp_emit_claude_json "$src"
    fi
    ;;
  8)
    if [[ "$mode" == "2" ]]; then
      _mcp_write_gemini_settings "$src"
    else
      _mcp_emit_gemini_json "$src"
    fi
    ;;
  9)
    if [[ "$mode" == "2" ]]; then
      local kimi_dst="$HOME/.kimi/mcp.json"
      mkdir -p "$(dirname "$kimi_dst")"
      _mcp_emit_kimi_json "$src" >"$kimi_dst"
      echo "converted MCP ($(_mcp_detect_source_type "$src")) -> Kimi MCP: $kimi_dst"
    else
      _mcp_emit_kimi_json "$src"
    fi
    ;;
  10)
    if [[ "$mode" == "2" ]]; then
      _mcp_write_codex_config "$src"
    else
      _mcp_emit_codex_toml "$src"
    fi
    ;;
  11)
    if [[ "$mode" == "2" ]]; then
      mcp_convert_cursor_all "$src"
      local cursor_dst="$HOME/.cursor/mcp.json"
      local claude_dst=".mcp.json"
      local kimi_dst="$HOME/.kimi/mcp.json"
      local kilo_dst="$HOME/.config/kilo/kilo.json"
      local crush_dst="$HOME/.config/crush/crush.json"
      mkdir -p "$(dirname "$cursor_dst")"
      mkdir -p "$(dirname "$kimi_dst")"
      mkdir -p "$(dirname "$kilo_dst")"
      mkdir -p "$(dirname "$crush_dst")"
      _mcp_emit_cursor_json "$src" >"$cursor_dst"
      _mcp_emit_claude_json "$src" >"$claude_dst"
      _mcp_emit_kimi_json "$src" >"$kimi_dst"
      _mcp_emit_kilo_json "$src" >"$kilo_dst"
      _mcp_emit_crush_json "$src" >"$crush_dst"
      _mcp_write_gemini_settings "$src"
      _mcp_write_codex_config "$src"
      echo "converted MCP ($(_mcp_detect_source_type "$src")) -> Cursor MCP: $cursor_dst"
      echo "converted MCP ($(_mcp_detect_source_type "$src")) -> Claude Code MCP: $claude_dst"
      echo "converted MCP ($(_mcp_detect_source_type "$src")) -> Kimi MCP: $kimi_dst"
      echo "converted MCP ($(_mcp_detect_source_type "$src")) -> Kilo MCP: $kilo_dst"
      echo "converted MCP ($(_mcp_detect_source_type "$src")) -> Crush MCP: $crush_dst"
    else
      echo "===== Factory ====="
      _mcp_emit_factory_json "$src"
      echo
      echo "===== OpenCode ====="
      _mcp_emit_opencode_json "$src"
      echo
      echo "===== Kilo ====="
      _mcp_emit_kilo_json "$src"
      echo
      echo "===== Crush ====="
      _mcp_emit_crush_json "$src"
      echo
      echo "===== Cursor ====="
      _mcp_emit_cursor_json "$src"
      echo
      echo "===== Claude Code ====="
      _mcp_emit_claude_json "$src"
      echo
      echo "===== Gemini CLI ====="
      _mcp_emit_gemini_json "$src"
      echo
      echo "===== Kimi CLI ====="
      _mcp_emit_kimi_json "$src"
      echo
      echo "===== Codex CLI (TOML) ====="
      _mcp_emit_codex_toml "$src"
      echo
      echo "===== Goose ====="
      mcp_convert_cursor_to_goose "$src"
    fi
    ;;
  *)
    echo "Invalid target choice: $target" >&2
    if [[ "$cleanup_tmp" == "1" ]]; then
      rm -f "$src"
    fi
    return 1
    ;;
  esac

  if [[ "$cleanup_tmp" == "1" ]]; then
    rm -f "$src"
  fi
}

# @description convert MCP config to target platform (source can be Cursor/Factory/OpenCode/Kilo/Crush/Gemini/Kimi/Claude)
# @param $1 target: factory|opencode|kilo|crush|goose|cursor|claude|gemini|kimi|codex|all
# @param $2 source mcp json (optional)
# @param $3 --write (optional: write to default target path(s))
# @example mcp_convert_to opencode ~/.factory/mcp.json
# @category ai
mcp_convert_to() {
  _mcp_require_jq || return 1

  local target="$1"
  local src_arg="$2"
  local mode="$3"
  local src
  src="$(_mcp_detect_source_file "$src_arg")"

  if [[ -z "$target" ]]; then
    echo "Usage: mcp_convert_to <factory|opencode|kilo|crush|goose|cursor|claude|gemini|kimi|codex|all> [source.json] [--write]" >&2
    return 1
  fi
  if [[ -z "$src" || ! -f "$src" ]]; then
    echo "MCP config not found. Pass a source file path." >&2
    return 1
  fi
  _mcp_require_json_source "$src" || return 1

  case "$target" in
  factory)
    if [[ "$mode" == "--write" ]]; then
      mcp_convert_cursor_to_factory "$src"
    else
      _mcp_emit_factory_json "$src"
    fi
    ;;
  opencode)
    if [[ "$mode" == "--write" ]]; then
      mcp_convert_cursor_to_opencode "$src"
    else
      _mcp_emit_opencode_json "$src"
    fi
    ;;
  kilo)
    if [[ "$mode" == "--write" ]]; then
      mcp_convert_cursor_to_kilo "$src"
    else
      _mcp_emit_kilo_json "$src"
    fi
    ;;
  crush)
    if [[ "$mode" == "--write" ]]; then
      mcp_convert_cursor_to_crush "$src"
    else
      _mcp_emit_crush_json "$src"
    fi
    ;;
  goose)
    mcp_convert_cursor_to_goose "$src"
    ;;
  cursor)
    if [[ "$mode" == "--write" ]]; then
      local cursor_dst="$HOME/.cursor/mcp.json"
      mkdir -p "$(dirname "$cursor_dst")"
      _mcp_emit_cursor_json "$src" >"$cursor_dst"
      echo "converted MCP ($(_mcp_detect_source_type "$src")) -> Cursor MCP: $cursor_dst"
    else
      _mcp_emit_cursor_json "$src"
    fi
    ;;
  claude)
    if [[ "$mode" == "--write" ]]; then
      local claude_dst=".mcp.json"
      _mcp_emit_claude_json "$src" >"$claude_dst"
      echo "converted MCP ($(_mcp_detect_source_type "$src")) -> Claude Code MCP: $claude_dst"
    else
      _mcp_emit_claude_json "$src"
    fi
    ;;
  gemini)
    if [[ "$mode" == "--write" ]]; then
      _mcp_write_gemini_settings "$src"
    else
      _mcp_emit_gemini_json "$src"
    fi
    ;;
  kimi)
    if [[ "$mode" == "--write" ]]; then
      local kimi_dst="$HOME/.kimi/mcp.json"
      mkdir -p "$(dirname "$kimi_dst")"
      _mcp_emit_kimi_json "$src" >"$kimi_dst"
      echo "converted MCP ($(_mcp_detect_source_type "$src")) -> Kimi MCP: $kimi_dst"
    else
      _mcp_emit_kimi_json "$src"
    fi
    ;;
  codex)
    if [[ "$mode" == "--write" ]]; then
      _mcp_write_codex_config "$src"
    else
      _mcp_emit_codex_toml "$src"
    fi
    ;;
  all)
    if [[ "$mode" == "--write" ]]; then
      mcp_convert_cursor_all "$src"
      local cursor_dst="$HOME/.cursor/mcp.json"
      local claude_dst=".mcp.json"
      local kimi_dst="$HOME/.kimi/mcp.json"
      mkdir -p "$(dirname "$cursor_dst")"
      mkdir -p "$(dirname "$kimi_dst")"
      _mcp_emit_cursor_json "$src" >"$cursor_dst"
      _mcp_emit_claude_json "$src" >"$claude_dst"
      _mcp_emit_kimi_json "$src" >"$kimi_dst"
      _mcp_write_gemini_settings "$src"
      _mcp_write_codex_config "$src"
      echo "converted MCP ($(_mcp_detect_source_type "$src")) -> Cursor MCP: $cursor_dst"
      echo "converted MCP ($(_mcp_detect_source_type "$src")) -> Claude Code MCP: $claude_dst"
      echo "converted MCP ($(_mcp_detect_source_type "$src")) -> Kimi MCP: $kimi_dst"
    else
      echo "===== Factory ====="
      _mcp_emit_factory_json "$src"
      echo
      echo "===== OpenCode ====="
      _mcp_emit_opencode_json "$src"
      echo
      echo "===== Kilo ====="
      _mcp_emit_kilo_json "$src"
      echo
      echo "===== Crush ====="
      _mcp_emit_crush_json "$src"
      echo
      echo "===== Cursor ====="
      _mcp_emit_cursor_json "$src"
      echo
      echo "===== Claude Code ====="
      _mcp_emit_claude_json "$src"
      echo
      echo "===== Gemini CLI ====="
      _mcp_emit_gemini_json "$src"
      echo
      echo "===== Kimi CLI ====="
      _mcp_emit_kimi_json "$src"
      echo
      echo "===== Codex CLI (TOML) ====="
      _mcp_emit_codex_toml "$src"
      echo
      echo "===== Goose ====="
      mcp_convert_cursor_to_goose "$src"
    fi
    ;;
  *)
    echo "Invalid target: $target" >&2
    echo "Usage: mcp_convert_to <factory|opencode|kilo|crush|goose|cursor|claude|gemini|kimi|codex|all> [source.json] [--write]" >&2
    return 1
    ;;
  esac
}

# @description print MCP config converted to a target format using flag-style CLI args
# @param --from source type hint: auto|cursor|factory|claude|gemini|kimi|opencode|kilo|crush|codex
# @param --to target type: cursor|factory|claude|gemini|kimi|opencode|kilo|crush|codex
# @param --input source MCP config path
# @example mcp_convert_to_print --from auto --to kilo --input ~/.cursor/mcp.json
# @category ai
mcp_convert_to_print() {
  _mcp_require_jq || return 1

  local from="auto"
  local target=""
  local input=""
  local src_json=""
  local cleanup_tmp=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
    --from)
      if [[ -z "$2" ]]; then
        echo "Missing value for --from" >&2
        return 1
      fi
      from="$2"
      shift 2
      ;;
    --to)
      if [[ -z "$2" ]]; then
        echo "Missing value for --to" >&2
        return 1
      fi
      target="$2"
      shift 2
      ;;
    --input)
      if [[ -z "$2" ]]; then
        echo "Missing value for --input" >&2
        return 1
      fi
      input="$2"
      shift 2
      ;;
    --help|-h)
      cat <<'EOF'
Usage: mcp_convert_to_print --from <auto|cursor|factory|claude|gemini|kimi|opencode|kilo|crush|codex> --to <cursor|factory|claude|gemini|kimi|opencode|kilo|crush|codex> --input <path>

Prints the converted config to stdout.
Notes:
  - JSON targets print JSON
  - codex prints TOML
  - goose is not supported by this command
EOF
      return 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      echo "Run: mcp_convert_to_print --help" >&2
      return 1
      ;;
    esac
  done

  case "$from" in
  auto|cursor|factory|claude|gemini|kimi|opencode|kilo|crush|codex)
    ;;
  *)
    echo "Invalid --from value: $from" >&2
    echo "Run: mcp_convert_to_print --help" >&2
    return 1
    ;;
  esac

  case "$target" in
  cursor|factory|claude|gemini|kimi|opencode|kilo|crush|codex)
    ;;
  "")
    echo "Missing required --to" >&2
    echo "Run: mcp_convert_to_print --help" >&2
    return 1
    ;;
  *)
    echo "Invalid --to value: $target" >&2
    echo "Run: mcp_convert_to_print --help" >&2
    return 1
    ;;
  esac

  if [[ -z "$input" ]]; then
    echo "Missing required --input" >&2
    echo "Run: mcp_convert_to_print --help" >&2
    return 1
  fi
  if [[ ! -f "$input" ]]; then
    echo "Input file not found: $input" >&2
    return 1
  fi

  src_json="$(_mcp_prepare_source_json "$input")" || return 1
  [[ "$src_json" == /tmp/mcp-from-toml.*.json ]] && cleanup_tmp=1

  case "$target" in
  cursor)
    _mcp_emit_cursor_json "$src_json"
    ;;
  factory)
    _mcp_emit_factory_json "$src_json"
    ;;
  claude)
    _mcp_emit_claude_json "$src_json"
    ;;
  gemini)
    _mcp_emit_gemini_json "$src_json"
    ;;
  kimi)
    _mcp_emit_kimi_json "$src_json"
    ;;
  opencode)
    _mcp_emit_opencode_json "$src_json"
    ;;
  kilo)
    _mcp_emit_kilo_json "$src_json"
    ;;
  crush)
    _mcp_emit_crush_json "$src_json"
    ;;
  codex)
    _mcp_emit_codex_toml "$src_json"
    ;;
  esac

  if [[ "$cleanup_tmp" == "1" ]]; then
    rm -f "$src_json"
  fi
}

_mcp_emit_add_commands_claude() {
  local src="$1"
  _mcp_extract_servers "$src" | jq -r '
    def secv($k; $v):
      if (env.MCP_SHOW_SECRETS == "1") then $v
      elif (($k|ascii_downcase|test("token|key|secret|password|authorization"))) then "__REDACTED__"
      else $v end;
    to_entries[]
    | .key as $name
    | .value as $v
    | if ($v.url? and (($v.url|type) == "string")) then
        "claude mcp add -s " + (env.MCP_CLAUDE_SCOPE // "user")
        + " --transport "
        + (if $v.type == "sse" then "sse" else "http" end)
        + " " + ($name|@sh)
        + " " + ($v.url|@sh)
        + (if $v.headers then
             " " + (($v.headers|to_entries|map("--header=" + ((.key + ": " + secv(.key; .value))|@sh))|join(" ")))
           else "" end)
      elif ($v.command? and (($v.command|type) == "string")) then
        "claude mcp add -s " + (env.MCP_CLAUDE_SCOPE // "user")
        + " --transport stdio "
        + (if $v.env then
             (($v.env|to_entries|map("--env=" + ((.key + "=" + secv(.key; .value))|@sh))|join(" ")) + " ")
           else "" end)
        + ($name|@sh)
        + " -- "
        + (([$v.command] + ($v.args // []))|map(@sh)|join(" "))
      else empty end
  '
}

_mcp_emit_add_commands_gemini() {
  local src="$1"
  _mcp_extract_servers "$src" | jq -r '
    def secv($k; $v):
      if (env.MCP_SHOW_SECRETS == "1") then $v
      elif (($k|ascii_downcase|test("token|key|secret|password|authorization"))) then "__REDACTED__"
      else $v end;
    to_entries[]
    | .key as $name
    | .value as $v
    | if ($v.url? and (($v.url|type) == "string")) then
        "gemini mcp add --transport "
        + (if $v.type == "sse" then "sse" else "http" end)
        + " " + ($name|@sh)
        + " " + ($v.url|@sh)
        + (if $v.headers then
             " " + (($v.headers|to_entries|map("-H " + ((.key + ": " + secv(.key; .value))|@sh))|join(" ")))
           else "" end)
      elif ($v.command? and (($v.command|type) == "string")) then
        "gemini mcp add "
        + (if $v.env then
             (($v.env|to_entries|map("-e " + ((.key + "=" + secv(.key; .value))|@sh))|join(" ")) + " ")
           else "" end)
        + ($name|@sh)
        + " "
        + (([$v.command] + ($v.args // []))|map(@sh)|join(" "))
      else empty end
  '
}

_mcp_emit_add_commands_kimi() {
  local src="$1"
  _mcp_extract_servers "$src" | jq -r '
    def secv($k; $v):
      if (env.MCP_SHOW_SECRETS == "1") then $v
      elif (($k|ascii_downcase|test("token|key|secret|password|authorization"))) then "__REDACTED__"
      else $v end;
    to_entries[]
    | .key as $name
    | .value as $v
    | if ($v.url? and (($v.url|type) == "string")) then
        "kimi mcp add --transport "
        + (if $v.type == "sse" then "sse" else "http" end)
        + " " + ($name|@sh)
        + " " + ($v.url|@sh)
        + (if $v.headers then
             " " + (($v.headers|to_entries|map("--header " + ((.key + ": " + secv(.key; .value))|@sh))|join(" ")))
           else "" end)
      elif ($v.command? and (($v.command|type) == "string")) then
        "kimi mcp add --transport stdio "
        + (if $v.env then
             (($v.env|to_entries|map("--env " + ((.key + "=" + secv(.key; .value))|@sh))|join(" ")) + " ")
           else "" end)
        + ($name|@sh)
        + " -- "
        + (([$v.command] + ($v.args // []))|map(@sh)|join(" "))
      else empty end
  '
}

_mcp_emit_add_commands_factory() {
  local src="$1"
  _mcp_extract_servers "$src" | jq -r '
    def secv($k; $v):
      if (env.MCP_SHOW_SECRETS == "1") then $v
      elif (($k|ascii_downcase|test("token|key|secret|password|authorization"))) then "__REDACTED__"
      else $v end;
    to_entries[]
    | .key as $name
    | .value as $v
    | if ($v.url? and (($v.url|type) == "string")) then
        "droid mcp add "
        + ($name|@sh)
        + " " + ($v.url|@sh)
        + " --type http"
        + (if $v.headers then
             " " + (($v.headers|to_entries|map("--header " + ((.key + ": " + secv(.key; .value))|@sh))|join(" ")))
           else "" end)
      elif ($v.command? and (($v.command|type) == "string")) then
        "droid mcp add "
        + ($name|@sh)
        + " "
        + ((([$v.command] + ($v.args // []))|join(" "))|@sh)
        + (if $v.env then
             " " + (($v.env|to_entries|map("--env " + ((.key + "=" + secv(.key; .value))|@sh))|join(" "))
           ) else "" end)
      else empty end
  '
}

_mcp_emit_add_commands_codex() {
  local src="$1"
  _mcp_extract_servers "$src" | jq -r '
    def secv($k; $v):
      if (env.MCP_SHOW_SECRETS == "1") then $v
      elif (($k|ascii_downcase|test("token|key|secret|password|authorization"))) then "__REDACTED__"
      else $v end;
    to_entries[]
    | .key as $name
    | .value as $v
    | if ($v.command? and (($v.command|type) == "string")) then
        "codex mcp add "
        + ($name|@sh)
        + " "
        + (if $v.env then
             (($v.env|to_entries|map("--env " + ((.key + "=" + secv(.key; .value))|@sh))|join(" ")) + " ")
           else "" end)
        + "-- "
        + (([$v.command] + ($v.args // []))|map(@sh)|join(" "))
      elif ($v.url? and (($v.url|type) == "string")) then
        "# remote server " + ($name|@sh) + " -> please configure in ~/.codex/config.toml (url/http_headers)"
      else empty end
  '
}

_mcp_emit_add_commands_opencode() {
  local src="$1"
  _mcp_extract_servers "$src" | jq -r '
    def secv($k; $v):
      if (env.MCP_SHOW_SECRETS == "1") then $v
      elif (($k|ascii_downcase|test("token|key|secret|password|authorization"))) then "__REDACTED__"
      else $v end;
    to_entries[]
    | .key as $name
    | .value as $v
    | "opencode mcp add"
      + " # name=" + ($name|@json)
      + (if ($v.url? and (($v.url|type) == "string")) then
           " type=remote url=" + ($v.url|@json)
           + (if $v.headers then
                " headers=" + (($v.headers|to_entries|map(.key + ": " + secv(.key; .value))|join("; "))|@json)
              else "" end)
         elif ($v.command? and (($v.command|type) == "string")) then
           " type=local command="
           + (([$v.command] + ($v.args // []))|join(" ")|@json)
           + (if $v.env then
                " env=" + (($v.env|to_entries|map(.key + "=" + secv(.key; .value))|join(" "))|@json)
              else "" end)
         else
           " # unsupported schema; configure manually"
         end)
  '
}

_mcp_emit_add_commands_kilo() {
  local src="$1"
  _mcp_extract_servers "$src" | jq -r '
    def secv($k; $v):
      if (env.MCP_SHOW_SECRETS == "1") then $v
      elif (($k|ascii_downcase|test("token|key|secret|password|authorization"))) then "__REDACTED__"
      else $v end;
    to_entries[]
    | .key as $name
    | .value as $v
    | "kilo mcp add"
      + " # name=" + ($name|@json)
      + (if ($v.url? and (($v.url|type) == "string")) then
           " type=remote url=" + ($v.url|@json)
           + (if $v.headers then
                " headers=" + (($v.headers|to_entries|map(.key + ": " + secv(.key; .value))|join("; "))|@json)
              else "" end)
         elif ($v.command? and (($v.command|type) == "string")) then
           " type=local command="
           + (([$v.command] + ($v.args // []))|join(" ")|@json)
           + (if $v.env then
                " env=" + (($v.env|to_entries|map(.key + "=" + secv(.key; .value))|join(" "))|@json)
              else "" end)
         else
           " # unsupported schema; configure manually"
         end)
  '
}

_mcp_emit_add_commands_goose() {
  local src="$1"
  _mcp_extract_servers "$src" | jq -r '
    def secv($k; $v):
      if (env.MCP_SHOW_SECRETS == "1") then $v
      elif (($k|ascii_downcase|test("token|key|secret|password|authorization"))) then "__REDACTED__"
      else $v end;
    to_entries[]
    | .key as $name
    | .value as $v
    | "goose configure"
      + " # Add Extension -> "
      + (if ($v.url? and (($v.url|type) == "string")) then
           "Remote Extension (Streamable HTTP)"
           + " -> name=" + ($name|@json)
           + " url=" + ($v.url|@json)
           + (if $v.headers then
                " headers=" + (($v.headers|to_entries|map(.key + ": " + secv(.key; .value))|join("; "))|@json)
              else "" end)
         elif ($v.command? and (($v.command|type) == "string")) then
           "Command-line Extension"
           + " -> name=" + ($name|@json)
           + " command=" + (([$v.command] + ($v.args // []))|join(" ")|@json)
           + (if $v.env then
                " env=" + (($v.env|to_entries|map(.key + "=" + secv(.key; .value))|join(" "))|@json)
              else "" end)
         else
           "configure manually for " + ($name|@json)
         end)
  '
}

_mcp_emit_add_commands_crush() {
  local src="$1"
  echo "# crush has no official 'mcp add'; merge these entries into .crush.json, crush.json, or \$HOME/.config/crush/crush.json under .mcp"
  _mcp_extract_servers "$src" | jq -c '
    def secv($k; $v):
      if (env.MCP_SHOW_SECRETS == "1") then $v
      elif (($k|ascii_downcase|test("token|key|secret|password|authorization"))) then "__REDACTED__"
      else $v end;
    to_entries[]
    | {
        (.key): (
          if (.value.url? and ((.value.url|type) == "string")) then
            {
              type: (if .value.type == "sse" then "sse" else "http" end),
              url: .value.url
            }
            + (if .value.headers? then {headers: (.value.headers | with_entries(.value = secv(.key; .value)))} else {} end)
            + (if .value.env? then {env: (.value.env | with_entries(.value = secv(.key; .value)))} else {} end)
            + (if .value.timeout? then {timeout: .value.timeout} else {} end)
            + (if .value.disabled_tools? then {disabled_tools: .value.disabled_tools} else {} end)
            + {disabled: (if .value.disabled == true then true else false end)}
          elif (.value.command? and ((.value.command|type) == "string")) then
            {
              type: "stdio",
              command: .value.command
            }
            + (if .value.args? then {args: .value.args} else {} end)
            + (if .value.env? then {env: (.value.env | with_entries(.value = secv(.key; .value)))} else {} end)
            + (if .value.timeout? then {timeout: .value.timeout} else {} end)
            + (if .value.disabled_tools? then {disabled_tools: .value.disabled_tools} else {} end)
            + {disabled: (if .value.disabled == true then true else false end)}
          else
            .value
          end
        )
      }
  '
}

# @description generate MCP add-command lines or setup hints for a target CLI from source MCP JSON/TOML
# @param $1 target: claude|gemini|kimi|factory|codex|opencode|kilo|goose|crush|all
# @param $2 source mcp json (optional)
# @example mcp_generate_add_commands claude ~/.cursor/mcp.json
# @category ai
mcp_generate_add_commands() {
  _mcp_require_jq || return 1

  local target="$1"
  local src_arg="$2"
  local src
  local src_json
  local cleanup_tmp=0
  src="$(_mcp_detect_source_file "$src_arg")"

  if [[ -z "$target" ]]; then
    echo "Usage: mcp_generate_add_commands <claude|gemini|kimi|factory|codex|opencode|kilo|goose|crush|all> [source.json]" >&2
    return 1
  fi
  if [[ -z "$src" || ! -f "$src" ]]; then
    echo "MCP config not found. Pass a source file path." >&2
    return 1
  fi
  src_json="$(_mcp_prepare_source_json "$src")" || return 1
  [[ "$src_json" == /tmp/mcp-from-toml.*.json ]] && cleanup_tmp=1

  case "$target" in
  claude)
    _mcp_emit_add_commands_claude "$src_json"
    ;;
  gemini)
    _mcp_emit_add_commands_gemini "$src_json"
    ;;
  kimi)
    _mcp_emit_add_commands_kimi "$src_json"
    ;;
  factory)
    _mcp_emit_add_commands_factory "$src_json"
    ;;
  codex)
    _mcp_emit_add_commands_codex "$src_json"
    ;;
  opencode)
    _mcp_emit_add_commands_opencode "$src_json"
    ;;
  kilo)
    _mcp_emit_add_commands_kilo "$src_json"
    ;;
  goose)
    _mcp_emit_add_commands_goose "$src_json"
    ;;
  crush)
    _mcp_emit_add_commands_crush "$src_json"
    ;;
  all)
    echo "===== claude ====="
    _mcp_emit_add_commands_claude "$src_json"
    echo
    echo "===== gemini ====="
    _mcp_emit_add_commands_gemini "$src_json"
    echo
    echo "===== kimi ====="
    _mcp_emit_add_commands_kimi "$src_json"
    echo
    echo "===== factory ====="
    _mcp_emit_add_commands_factory "$src_json"
    echo
    echo "===== codex ====="
    _mcp_emit_add_commands_codex "$src_json"
    echo
    echo "===== opencode ====="
    _mcp_emit_add_commands_opencode "$src_json"
    echo
    echo "===== kilo ====="
    _mcp_emit_add_commands_kilo "$src_json"
    echo
    echo "===== goose ====="
    _mcp_emit_add_commands_goose "$src_json"
    echo
    echo "===== crush ====="
    _mcp_emit_add_commands_crush "$src_json"
    ;;
  *)
    echo "Invalid target: $target" >&2
    echo "Usage: mcp_generate_add_commands <claude|gemini|kimi|factory|codex|opencode|kilo|goose|crush|all> [source.json]" >&2
    if [[ "$cleanup_tmp" == "1" ]]; then
      rm -f "$src_json"
    fi
    return 1
    ;;
  esac

  if [[ "$cleanup_tmp" == "1" ]]; then
    rm -f "$src_json"
  fi
}
