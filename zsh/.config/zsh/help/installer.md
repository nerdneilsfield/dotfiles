# Installer

安装系统现在分为三层：

1. `install_*`：工具级安装命令（主入口，兼容原有习惯）。
2. `install_smart_tool <tool>`：统一入口，走策略化路由。
3. `install_route <tool> [--policy ...] [--method ...]`：底层路由器。

## 快速使用

- `install_help ripgrep`：查看某工具的路由策略和版本门槛
- `install_smart_tool ripgrep`：按默认策略安装（默认 `latest`）
- `install_route ripgrep --method pkg`：强制只走系统包管理器
- `smart_install ripgrep`：通用包安装（等价于 `install_with_manager ripgrep`）

## 策略与环境变量

- `INSTALL_POLICY`
  - `latest`（默认）：`release -> registry -> pkg -> source`
  - `stable`：`pkg -> release -> registry -> source`
- `INSTALL_METHOD`
  - `auto`（默认）或 `pkg|registry|release|source`
  - 非 `auto` 时只走指定方法，不做 fallback
- `INSTALL_VERBOSE`
  - `1`（默认）输出路由日志
  - `0` 仅输出错误

## 典型场景

### 1) 我想尽量新

```zsh
INSTALL_POLICY=latest install_smart_tool fzf
```

### 2) 我只想用系统包（更稳）

```zsh
INSTALL_METHOD=pkg install_route ripgrep
```

### 3) 查看为什么走了某条路径

```zsh
INSTALL_VERBOSE=1 install_route yazi
```

你会看到类似：

```text
[install:info] tool=yazi policy=latest method=release state=try
[install:warn] tool=yazi policy=latest method=release state=fallback reason=failed
[install:info] tool=yazi policy=latest method=registry state=try
[install:info] tool=yazi policy=latest chosen=registry result=success
```

## 相关文件

- `~/.config/zsh/install_catalog.zsh`
- `~/.config/zsh/install_router.zsh`
- `~/.config/zsh/installers.zsh`
- `~/.config/zsh/package_manager.zsh`

## AI CLI 安装命令（新增）

- `install_openspec_cli`
- `install_factory_droid`
- `install_goose_cli`
- `install_opencode_cli`
- `install_cursh_cli`
- `install_cursor_cli`

批量更新：

```zsh
update_ai_tools
```

重装：

```zsh
reinstall_ai_tools
```

MCP 配置转换（跨平台）：

```zsh
show-help mcp
```
