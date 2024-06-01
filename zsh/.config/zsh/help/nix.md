# Nix 使用说明

Nix 是一个功能强大的包管理器，适用于 Linux 和其他 Unix 系统。以下是一些常用的 Nix 命令及其简要说明:

## Nix 的使用说明

1. **安装和升级 Nix**：

   - 安装 Nix（单用户模式）：
     ```bash
     sh <(curl -L https://nixos.org/nix/install) --no-daemon
     ```
   - 安装 Nix（多用户模式）：
     ```bash
     sh <(curl -L https://nixos.org/nix/install) --daemon
     ```
   - 升级 Nix：
     ```bash
     nix upgrade-nix
     ```

2. **包管理**：

   - 安装包：
     ```bash
     nix-env -i <pkg-name>
     ```
   - 卸载包：
     ```bash
     nix-env -e <pkg-name>
     ```
   - 列出已安装的包：
     ```bash
     nix-env -q
     ```
   - 搜索包：
     ```bash
     nix search <pkg-name>
     ```

3. **构建和开发**：

   - 构建包：
     ```bash
     nix-build <path-to-nix-expression>
     ```
   - 进入开发环境：
     ```bash
     nix-shell <path-to-nix-expression>
     ```

4. **垃圾回收**：

   - 运行垃圾回收以清理未使用的包：
     ```bash
     nix-collect-garbage
     ```
   - 强制垃圾回收：
     ```bash
     nix-collect-garbage -d
     ```

5. **管理 Nix 通道**：

   - 添加通道：
     ```bash
     nix-channel --add <url> <channel-name>
     ```
   - 更新通道：
     ```bash
     nix-channel --update
     ```

6. **Nix Flakes（实验性功能）**：
   - 初始化一个新的 Flake 项目：
     ```bash
     nix flake init
     ```
   - 更新 Flake 锁文件：
     ```bash
     nix flake update
     ```
   - 构建 Flake：
     ```bash
     nix build
     ```

## 提供的 Nix 辅助函数:

- `install-nix`: 安装 `nix`
- `install-nix-china`: 在中国安装 `nix`
- `uninstall-nix`: 卸载 `nix`
- `update-nix`: 更新 `nix`
- `update-nix-china`: 在中国更新 `nix`
- `set-nix-channel-tuna`: 使用 `nix-channel` 的清华大学镜像
