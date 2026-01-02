# fd

友好的 find 替代。

## 常用命令
- `fd PATTERN [PATH]`
- `fd -t f -e rs`
- `fd -H PATTERN`
- `fd -I PATTERN`
- `fd -L PATTERN`
- `fd -a PATTERN`
- `fd PATTERN -x cmd {}`

## 常用参数
- `-t` 类型: f/d/l
- `-e` 扩展名过滤
- `-H` 搜索隐藏文件
- `-I` 忽略 .gitignore
- `-L` 跟随软链
- `--max-depth/--min-depth` 深度
- `--exclude` 排除目录
- `-x/-X` 执行命令

## 使用案例
- `fd -t f -e rs src` 在 src 内找 Rust 文件
- `fd -t d node_modules` 找目录
- `fd -H -I \"\\.env\"` 查找隐藏配置
- `fd -e md -x rg \"TODO\" {}` 在匹配文件中搜索
- `fd -t f -e log -x rm {}` 批量删除日志（小心）

## 配合使用
- `fd -t f | fzf` 文件选择器
- `fd -t f -e md | fzf --preview 'bat --style=numbers --color=always {}'`
- `fd -t f -e go | xargs rg \"TODO\"` 结合 rg 搜索

## 参考
- https://github.com/sharkdp/fd
