#!/usr/bin/env zsh
# 导航系统测试脚本

##
# @brief Test navigation system functionality
# @return 0 on success
# @example test_navigation_system
# @category test
##
test_navigation_system() {
    echo "🧭 导航系统功能测试"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # 检查必要函数
    echo "🔍 检查导航相关函数..."
    local nav_functions=(
        "install_zoxide"
        "install_zoxide_from_github"
        "init_navigation"
        "check_navigation_status"
        "show_navigation_help"
    )
    
    for func in "${nav_functions[@]}"; do
        if command -v "$func" >/dev/null 2>&1; then
            echo "✅ $func - 可用"
        else
            echo "❌ $func - 不可用"
        fi
    done
    
    echo ""
    echo "🔗 检查别名..."
    local nav_aliases=("nav-status" "nav-help" "install-zoxide")
    
    for alias_name in "${nav_aliases[@]}"; do
        if alias "$alias_name" >/dev/null 2>&1; then
            echo "✅ $alias_name - 可用"
        else
            echo "❌ $alias_name - 不可用"
        fi
    done
    
    echo ""
    echo "🎯 检查导航工具状态..."
    
    # 检查 zoxide
    if command -v zoxide >/dev/null 2>&1; then
        echo "✅ zoxide - 已安装 ($(zoxide --version))"
        echo "🎯 主要导航工具: zoxide"
    else
        echo "❌ zoxide - 未安装"
    fi
    
    # 检查 z.lua
    if [[ -f "$ZSH_CONF_DIR/z.lua" ]]; then
        if command -v lua >/dev/null 2>&1; then
            echo "✅ z.lua - 可用作备选"
        else
            echo "⚠️  z.lua - 文件存在但缺少 lua"
        fi
    else
        echo "❌ z.lua - 文件不存在"
    fi
    
    # 检查 z 命令
    if command -v z >/dev/null 2>&1; then
        echo "✅ z 命令 - 已绑定"
        local z_info=$(type z 2>/dev/null | head -1)
        echo "   类型: $z_info"
        
        # 检查是否是 zoxide 或 z.lua
        if type z | grep -q "zoxide"; then
            echo "   🎯 当前使用: zoxide"
        elif type z | grep -q "_zlua"; then
            echo "   🎯 当前使用: z.lua"
        else
            echo "   ❓ 无法确定 z 命令来源"
        fi
    else
        echo "❌ z 命令 - 未绑定"
    fi
    
    echo ""
    echo "📊 智能包管理器集成测试..."
    
    # 检查 install_smart_tool 是否支持 zoxide
    if command -v install_smart_tool >/dev/null 2>&1; then
        echo "✅ install_smart_tool - 可用"
        # 这里可以检查是否包含 zoxide 支持，但不实际安装
        echo "💡 支持通过 'install_smart_tool zoxide' 安装"
    else
        echo "❌ install_smart_tool - 不可用"
    fi
    
    echo ""
    echo "🧪 功能测试结果:"
    
    local score=0
    local total=6
    
    # 评分系统
    command -v install_zoxide >/dev/null 2>&1 && ((score++))
    command -v check_navigation_status >/dev/null 2>&1 && ((score++))
    command -v show_navigation_help >/dev/null 2>&1 && ((score++))
    alias nav-status >/dev/null 2>&1 && ((score++))
    alias nav-help >/dev/null 2>&1 && ((score++))
    [[ -f "$ZSH_CONF_DIR/navigation.zsh" ]] && ((score++))
    
    echo "📈 功能完整性: $score/$total"
    
    if [[ $score -eq $total ]]; then
        echo "🎉 导航系统配置完美！"
    elif [[ $score -ge 4 ]]; then
        echo "✅ 导航系统基本功能正常"
    else
        echo "⚠️  导航系统可能存在问题"
    fi
    
    echo ""
    echo "💡 使用建议:"
    if ! command -v zoxide >/dev/null 2>&1; then
        echo "   • 运行 'install_zoxide' 安装高性能导航工具"
    fi
    if ! command -v z >/dev/null 2>&1; then
        echo "   • 重新加载 shell 配置: source ~/.zshrc"
    fi
    echo "   • 运行 'nav-help' 查看使用指南"
    echo "   • 运行 'nav-status' 查看详细状态"
    
    echo ""
    echo "🎯 测试完成！"
}

# 如果直接运行此脚本，执行测试
if [[ "${BASH_SOURCE[0]}" == "${0}" ]] || [[ "${(%):-%x}" == "${0}" ]]; then
    # 确保加载必要的配置
    [[ -n "$ZSH_CONF_DIR" ]] || export ZSH_CONF_DIR="$(dirname "$0")"
    source "$ZSH_CONF_DIR/navigation.zsh"
    source "$ZSH_CONF_DIR/package_manager.zsh"
    
    test_navigation_system
fi