# 🔒 安全配置模板
# 复制此文件为 variables.zsh 并根据需要修改

# 代理配置 - 请根据实际情况修改
# 支持格式: http://host:port, socks5://host:port
# export _proxy="http://127.0.0.1:7890"
# export _gproxy="http://127.0.0.1:7890"

# 开发工具配置
export USE_VCPKG="OFF"

# GitHub Token (可选) - 提高API访问限制
# 获取地址: https://github.com/settings/tokens
# export GHHH_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# 🔐 安全提示:
# 1. 不要将此文件添加到版本控制系统
# 2. 确保文件权限为 600 (chmod 600 variables.zsh)
# 3. 定期更换敏感凭据
# 4. 使用环境变量而非硬编码敏感信息
