# ZSH 帮助系统

##
# @brief 显示所有可用函数的帮助信息
# @description 解析配置目录中所有函数的注释，按分类显示
# @param $1 可选的分类过滤器 (install|config|check|network|tool|security|cache)
# @return 0 成功
# @example show_functions
# @example show_functions install
# @category tool
##
show_functions() {
    local category_filter="$1"
    local config_dir="${ZSH_CONF_DIR:-$HOME/.config/zsh}"
    
    echo "📚 ZSH 配置函数文档"
    echo "=================="
    
    if [[ -n "$category_filter" ]]; then
        echo "🏷️  分类: $category_filter"
        echo ""
    fi
    
    # 临时文件存储解析结果
    local temp_file=$(mktemp)
    
    # 解析所有 .zsh 文件中的函数文档
    for file in "$config_dir"/*.zsh; do
        if [[ -f "$file" ]]; then
            _parse_function_docs "$file" "$category_filter" >> "$temp_file"
        fi
    done
    
    # 按分类排序并显示
    if [[ -s "$temp_file" ]]; then
        sort "$temp_file" | _format_function_docs
    else
        echo "❌ 未找到匹配的函数文档"
        if [[ -n "$category_filter" ]]; then
            echo "💡 可用分类: install, config, check, network, tool, security, cache"
        fi
    fi
    
    rm -f "$temp_file"
}

##
# @brief 解析单个文件中的函数文档
# @param $1 文件路径
# @param $2 分类过滤器 (可选)
# @category tool
##
_parse_function_docs() {
    local file="$1"
    local category_filter="$2"
    local filename=$(basename "$file")
    
    # 使用 awk 解析函数文档
    awk -v cat_filter="$category_filter" -v fname="$filename" '
    BEGIN {
        in_doc = 0
        brief = ""
        description = ""
        params = ""
        return_val = ""
        example = ""
        category = ""
        func_name = ""
    }
    
    # 检测文档开始
    /^##$/ && !in_doc {
        in_doc = 1
        next
    }
    
    # 检测文档结束
    /^##$/ && in_doc {
        in_doc = 0
        next
    }
    
    # 解析文档标签
    in_doc && /^# @brief/ {
        brief = substr($0, 9)
        next
    }
    
    in_doc && /^# @description/ {
        description = substr($0, 15)
        next
    }
    
    in_doc && /^# @param/ {
        param = substr($0, 9)
        if (params == "") params = param
        else params = params "\n                   " param
        next
    }
    
    in_doc && /^# @return/ {
        return_val = substr($0, 10)
        next
    }
    
    in_doc && /^# @example/ {
        example = substr($0, 11)
        next
    }
    
    in_doc && /^# @category/ {
        category = substr($0, 12)
        next
    }
    
    # 检测函数定义
    !in_doc && /^[a-zA-Z_][a-zA-Z0-9_]*\(\)/ {
        match($0, /^[a-zA-Z_][a-zA-Z0-9_]*/)
        func_name = substr($0, RSTART, RLENGTH)
        
        # 如果有分类过滤器，检查是否匹配
        if (cat_filter != "" && category != cat_filter) {
            # 重置变量
            brief = ""
            description = ""
            params = ""
            return_val = ""
            example = ""
            category = ""
            func_name = ""
            next
        }
        
        # 输出解析结果
        if (brief != "") {
            printf "%s|%s|%s|%s|%s|%s|%s|%s\n", 
                   category, func_name, brief, description, params, return_val, example, fname
        }
        
        # 重置变量
        brief = ""
        description = ""
        params = ""
        return_val = ""
        example = ""
        category = ""
        func_name = ""
    }
    ' "$file"
}

##
# @brief 格式化函数文档输出
# @category tool
##
_format_function_docs() {
    local current_category=""
    
    while IFS='|' read -r category func_name brief description params return_val example filename; do
        # 如果是新分类，显示分类标题
        if [[ "$category" != "$current_category" ]]; then
            if [[ -n "$current_category" ]]; then
                echo ""
            fi
            
            case "$category" in
                "install") echo "🔧 安装相关函数" ;;
                "config") echo "⚙️  配置相关函数" ;;
                "check") echo "🔍 检查验证函数" ;;
                "network") echo "🌐 网络代理函数" ;;
                "tool") echo "🛠️  工具辅助函数" ;;
                "security") echo "🔒 安全相关函数" ;;
                "cache") echo "💾 缓存相关函数" ;;
                *) echo "📁 其他函数" ;;
            esac
            echo "$(printf '%*s' 50 '' | tr ' ' '-')"
            current_category="$category"
        fi
        
        # 显示函数信息
        echo "📍 $func_name"
        echo "   💬 $brief"
        
        if [[ -n "$description" ]]; then
            echo "   📝 $description"
        fi
        
        if [[ -n "$params" ]]; then
            echo "   📥 参数: $params"
        fi
        
        if [[ -n "$return_val" ]]; then
            echo "   📤 返回: $return_val"
        fi
        
        if [[ -n "$example" ]]; then
            echo "   💡 示例: $example"
        fi
        
        echo "   📄 文件: $filename"
        echo ""
        
    done
}

##
# @brief 搜索函数
# @param $1 搜索关键词
# @return 0 找到匹配的函数
# @example search_functions docker
# @category tool
##
search_functions() {
    local keyword="$1"
    
    if [[ -z "$keyword" ]]; then
        echo "Usage: search_functions <keyword>"
        return 1
    fi
    
    echo "🔍 搜索函数: '$keyword'"
    echo "========================"
    
    local config_dir="${ZSH_CONF_DIR:-$HOME/.config/zsh}"
    local found=0
    
    for file in "$config_dir"/*.zsh; do
        if [[ -f "$file" ]]; then
            # 搜索函数名和注释
            local results=$(grep -n -A 10 -B 2 "$keyword" "$file" | grep -E "(^[0-9]+:##|^[0-9]+:# @|^[0-9]+:[a-zA-Z_][a-zA-Z0-9_]*\(\))")
            
            if [[ -n "$results" ]]; then
                echo "📄 $(basename "$file"):"
                echo "$results" | sed 's/^[0-9]*:/  /'
                echo ""
                found=1
            fi
        fi
    done
    
    if [[ $found -eq 0 ]]; then
        echo "❌ 未找到包含 '$keyword' 的函数"
    fi
    
    return $found
}

##
# @brief 显示 README.md 内容
# @param $1 可选的章节名称
# @return 0 成功
# @example show_readme
# @example show_readme "安装与配置"
# @category tool
##
show_readme() {
    local section="$1"
    local config_dir="${ZSH_CONF_DIR:-$HOME/.config/zsh}"
    local readme_file="$config_dir/README.md"
    
    if [[ ! -f "$readme_file" ]]; then
        echo "❌ 未找到 README.md 文件: $readme_file"
        return 1
    fi
    
    echo "📖 ZSH 配置文档"
    echo "==============="
    
    if [[ -n "$section" ]]; then
        echo "📍 章节: $section"
        echo ""
        
        # 搜索特定章节
        awk -v section="$section" '
        BEGIN { found = 0; in_section = 0 }
        
        # 匹配章节标题
        /^#/ && tolower($0) ~ tolower(section) {
            found = 1
            in_section = 1
            print $0
            next
        }
        
        # 如果找到了章节，继续打印直到下一个同级或更高级标题
        in_section && /^#/ && !( tolower($0) ~ tolower(section) ) {
            # 检查是否是同级或更高级标题
            level = 0
            for(i=1; i<=length($0); i++) {
                if(substr($0,i,1) == "#") level++
                else break
            }
            if(level <= start_level) in_section = 0
        }
        
        in_section { print $0 }
        
        # 记录开始章节的级别
        found && in_section && !start_level {
            start_level = 0
            for(i=1; i<=length($0); i++) {
                if(substr($0,i,1) == "#") start_level++
                else break
            }
        }
        
        END { if(!found) print "❌ 未找到章节: " section }
        ' "$readme_file"
    else
        # 显示整个 README
        if command -v bat >/dev/null 2>&1; then
            bat "$readme_file"
        elif command -v mdcat >/dev/null 2>&1; then
            mdcat "$readme_file"
        else
            cat "$readme_file"
        fi
    fi
}

##
# @brief 增强的帮助系统主入口
# @param $1 帮助类型 (functions|readme|search)
# @param $2 可选参数 (分类/章节/关键词)
# @return 0 成功
# @example show_help
# @example show_help functions install
# @example show_help readme "安装与配置"
# @example show_help search docker
# @category tool
##
show_help() {
    local help_type="$1"
    local param="$2"
    
    case "$help_type" in
        "functions"|"func"|"f")
            show_functions "$param"
            ;;
        "readme"|"doc"|"d")
            show_readme "$param"
            ;;
        "search"|"s")
            if [[ -z "$param" ]]; then
                echo "Usage: show_help search <keyword>"
                return 1
            fi
            search_functions "$param"
            ;;
        "")
            # 默认显示概览
            echo "🎯 ZSH 配置帮助系统"
            echo "==================="
            echo ""
            echo "📚 使用方法:"
            echo "  show_help functions [category]  # 显示函数文档"
            echo "  show_help readme [section]      # 显示 README"
            echo "  show_help search <keyword>      # 搜索函数"
            echo ""
            echo "🏷️  可用分类:"
            echo "  install, config, check, network, tool, security, cache"
            echo ""
            echo "💡 快捷别名:"
            echo "  show_functions [category]       # 显示函数"
            echo "  search_functions <keyword>      # 搜索函数"
            echo "  show_readme [section]           # 显示文档"
            ;;
        *)
            echo "❌ 未知的帮助类型: $help_type"
            echo "💡 可用类型: functions, readme, search"
            return 1
            ;;
    esac
}

# 便捷别名
alias help="show_help"
alias docs="show_help readme"
alias funcs="show_help functions"
alias search-func="search_functions"