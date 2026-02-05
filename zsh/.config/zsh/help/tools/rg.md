# ripgrep (rg)

极速文本搜索，替代 grep。

## 常用命令
- `rg PATTERN [PATH]`
- `rg -g "*.md" PATTERN`
- `rg -i PATTERN`
- `rg -n -C 2 PATTERN`
- `rg --files`
- `rg --files-with-matches PATTERN`
- `rg --json PATTERN`

## 常用参数
- `-g/--glob` glob 过滤
- `-i/--ignore-case` 忽略大小写
- `-S/--smart-case` 智能大小写
- `-F/--fixed-strings` 纯字符串匹配
- `--pcre2` 使用 PCRE2
- `--hidden` 搜索隐藏文件
- `--no-ignore` 忽略 .gitignore
- `-t/--type` 按类型筛选
- `--stats` 输出统计

## 配置
- `~/.ripgreprc`

## 使用案例
- `rg "TODO" src`
- `rg -g "*.md" "keyword"`
- `rg -n -C 2 "panic"`
- `rg --hidden --no-ignore ".env"`
- `rg -l "pattern"` 仅列出文件名

## 配合使用
- `rg --files | fzf`
- `rg "TODO" -l | fzf`
- `rg "pattern" -g "*.log" | less`

## 参考
- https://github.com/BurntSushi/ripgrep
