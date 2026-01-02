# bat

带语法高亮的 cat。

## 常用命令
- `bat file`
- `bat -n file`
- `bat -A file`
- `bat -p file`
- `bat --style=plain file`

## 常用参数
- `-n` 行号
- `-A` 显示不可见字符
- `-p/--plain` 纯文本
- `--style` 样式
- `--theme` 主题
- `--paging=never` 禁用分页
- `--language` 指定语言
- `--list-themes` 列出主题

## 配置
- `~/.config/bat/config`

## 使用案例
- `bat file`
- `bat -n file`
- `bat -A file`
- `bat --style=plain file`

## 配合使用
- `rg "TODO" -l | fzf --preview 'bat --style=numbers --color=always {}'`
- `git show | bat -l diff`

## 参考
- https://github.com/sharkdp/bat
