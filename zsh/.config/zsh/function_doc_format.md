# 函数文档格式规范

## 📋 标准注释格式

### 🎯 **基本格式**

```bash
##
# @brief 函数的简短描述 (一行)
# @description 详细描述 (可选，多行)
# @param $1 参数1的描述
# @param $2 参数2的描述 (可选)
# @return 0 成功, 1 失败
# @example function_name arg1 arg2
# @category 功能分类 (install|config|check|network|tool)
# @since v1.0.0 (可选)
##
function_name() {
    # 函数实现
}
```

### 🏷️ **标签说明**

- `@brief`: 简短描述（必需）
- `@description`: 详细描述（可选）
- `@param`: 参数说明（按需）
- `@return`: 返回值说明（推荐）
- `@example`: 使用示例（推荐）
- `@category`: 功能分类（必需）
- `@since`: 版本信息（可选）

### 📂 **分类标准**

- `install` - 安装相关函数
- `config` - 配置相关函数  
- `check` - 检查验证函数
- `network` - 网络代理函数
- `tool` - 工具辅助函数
- `security` - 安全相关函数
- `cache` - 缓存相关函数

### 📝 **示例**

```bash
##
# @brief 智能安装指定的开发工具
# @description 根据当前平台自动选择最佳的包管理器安装工具，支持 Homebrew、Pacman 等
# @param $1 工具名称 (fnm|rustup|docker|uv|pyenv 等)
# @return 0 安装成功, 1 安装失败
# @example install_smart_tool fnm
# @category install
##
install_smart_tool() {
    # 函数实现
}

##
# @brief 启用网络代理设置
# @param $1 代理地址 (格式: http://host:port)
# @return 0 设置成功
# @example proxy_enable http://127.0.0.1:7890
# @category network
##
proxy_enable() {
    # 函数实现
}
```