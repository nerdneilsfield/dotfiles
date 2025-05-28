# ZSH 函数命名规范

## 📋 统一命名规范

### 🎯 **核心原则**
- 使用下划线分隔 (`snake_case`)
- 动词在前，名词在后
- 保持简洁但清晰
- 分类明确

### 📂 **函数分类和命名规范**

#### 1. **安装类函数**
```bash
# 格式: install_<tool_name>[_variant]
install_docker          # 安装 Docker
install_docker_desktop  # 安装 Docker Desktop
install_python_tools    # 安装 Python 工具集
install_modern_tools    # 安装现代工具集

# 智能安装
install_smart_<tool>     # 智能安装特定工具
install_batch_<category> # 批量安装某类工具
```

#### 2. **配置类函数**
```bash
# 格式: setup_<component>[_variant]
setup_python_env        # 设置 Python 环境
setup_git_config       # 设置 Git 配置
setup_mirrors_china     # 设置中国镜像源

# 或使用 config_
config_docker_daemon    # 配置 Docker 守护进程
config_ssh_keys        # 配置 SSH 密钥
```

#### 3. **检查类函数**
```bash
# 格式: check_<what>[_condition]
check_system_deps      # 检查系统依赖
check_network_access   # 检查网络访问
check_tool_version     # 检查工具版本
```

#### 4. **获取类函数**
```bash
# 格式: get_<what>[_from_where]
get_latest_release     # 获取最新版本
get_system_info       # 获取系统信息
get_package_manager   # 获取包管理器
```

#### 5. **验证类函数**  
```bash
# 格式: validate_<what>
validate_url          # 验证 URL
validate_config       # 验证配置
validate_environment  # 验证环境
```

#### 6. **清理类函数**
```bash
# 格式: clean_<what>
clean_cache           # 清理缓存
clean_temp_files     # 清理临时文件
clean_old_versions   # 清理旧版本
```

#### 7. **工具类函数**
```bash
# 格式: <category>_<action>
cache_get            # 缓存获取
cache_set            # 缓存设置
proxy_enable         # 启用代理
proxy_disable        # 禁用代理
```

### 🔄 **重命名计划**

#### **Phase 1: 核心函数** (高优先级)
```bash
# 当前 -> 新名称
install_tool_smart -> install_smart_tool
smart_install -> install_with_manager
detect_package_manager -> get_package_manager
show_install_recommendations -> show_install_guide
```

#### **Phase 2: 安装函数** (中优先级)
```bash
# 统一 install_ 前缀
install_modertools_smart -> install_batch_modern
install_python_tools -> install_batch_python
install_rust_tools -> install_batch_rust
```

#### **Phase 3: 配置函数** (中优先级)
```bash
# 配置相关
set_cargo_mirrors -> setup_cargo_mirrors
set_python_mirror_cn -> setup_python_mirrors
init_mamba -> setup_mamba_env
```

#### **Phase 4: 工具函数** (低优先级)
```bash
# 工具类
testconn -> test_connectivity  
printpx -> show_proxy_status
setproxy -> proxy_enable
unsetproxy -> proxy_disable
```

### 📚 **别名策略**
为了向后兼容，保留旧函数名作为别名：
```bash
# 例子
alias install_tool_smart="install_smart_tool"
alias smart_install="install_with_manager"
```

### 🎨 **函数文档模板**
```bash
# <简短描述>
# 参数: $1 - <参数1描述>
#      $2 - <参数2描述> (可选)
# 返回: 0 - 成功, 1 - 失败
# 示例: <函数名> <示例参数>
function_name() {
    # 函数实现
}
```

### 🔍 **命名检查清单**
- [ ] 动词在前 (install, setup, check, get)
- [ ] 使用下划线分隔
- [ ] 描述性但简洁
- [ ] 符合分类规范
- [ ] 避免缩写 (除非广泛认知)
- [ ] 一致的参数风格

### 🎯 **实施计划**
1. **创建新函数**: 使用新命名规范
2. **添加别名**: 保持向后兼容
3. **逐步迁移**: 更新文档和示例  
4. **标记过时**: 在老函数中添加过时警告
5. **最终清理**: 在主要版本中移除老函数