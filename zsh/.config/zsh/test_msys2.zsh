#!/usr/bin/env zsh
# MSYS2 功能测试脚本

##
# @brief Test MSYS2 functionality
# @return 0 on success
# @example test_msys2_functions
# @category test
##
test_msys2_functions() {
    echo "🧪 MSYS2 功能测试"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # 模拟 MSYS2 环境进行测试
    local original_uname_output=""
    
    echo "🔍 测试平台检测..."
    
    # 测试正常情况
    echo "当前平台: $(get_platform)"
    echo "包管理器: $(get_package_manager)"
    echo "CPU架构: $(get_cpu_arch)"
    echo "架构变体: $(get_arch_variants)"
    echo ""
    
    # 测试 MSYS2 特定函数是否存在
    echo "🔧 检查 MSYS2 特定函数..."
    local msys2_functions=(
        "setup_msys2_environment"
        "install_msys2_packages" 
        "install_msys2_dev_tools"
        "install_msys2_modern_tools"
        "setup_msys2_languages"
        "setup_msys2_windows_integration"
        "install_msys2_language_tools"
        "show_msys2_info"
        "msys2_quick_setup"
    )
    
    for func in "${msys2_functions[@]}"; do
        if command -v "$func" >/dev/null 2>&1; then
            echo "✅ $func - 可用"
        else
            echo "❌ $func - 不可用"
        fi
    done
    
    echo ""
    echo "🔗 检查别名..."
    local msys2_aliases=("msys2-info" "msys2-setup" "msys2-install" "msys2-dev" "msys2-modern")
    
    for alias_name in "${msys2_aliases[@]}"; do
        if alias "$alias_name" >/dev/null 2>&1; then
            echo "✅ $alias_name - 可用"
        else
            echo "❌ $alias_name - 不可用"
        fi
    done
    
    echo ""
    echo "📋 MSYS2 配置文件检查..."
    if [[ -f "$ZSH_CONF_DIR/config.msys2.zsh" ]]; then
        echo "✅ config.msys2.zsh - 存在"
        echo "📄 文件大小: $(wc -l < "$ZSH_CONF_DIR/config.msys2.zsh") 行"
    else
        echo "❌ config.msys2.zsh - 不存在"
    fi
    
    echo ""
    echo "🎯 测试完成！"
    echo "💡 提示: 在真实的 MSYS2 环境中运行时会有更多功能可用"
}

# 如果直接运行此脚本，执行测试
if [[ "${BASH_SOURCE[0]}" == "${0}" ]] || [[ "${(%):-%x}" == "${0}" ]]; then
    # 确保加载必要的配置
    [[ -n "$ZSH_CONF_DIR" ]] || export ZSH_CONF_DIR="$(dirname "$0")"
    source "$ZSH_CONF_DIR/config.msys2.zsh"
    source "$ZSH_CONF_DIR/package_manager.zsh" 
    source "$ZSH_CONF_DIR/utils.zsh"
    
    test_msys2_functions
fi