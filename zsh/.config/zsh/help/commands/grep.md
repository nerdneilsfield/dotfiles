# grep

文本搜索工具。

## 常用命令
- `grep "pattern" file`
- `grep -n "pattern" file`
- `grep -r "pattern" dir`
- `grep -i "pattern" file`
- `grep -E "foo|bar" file`
- `grep -v "pattern" file` 反向匹配

## 常用参数
- `-n` 显示行号
- `-r` 递归
- `-i` 忽略大小写
- `-E` 扩展正则
- `-v` 反向匹配
- `-C 2` 上下文

## 使用案例
- `grep -n "TODO" -r src`
- `grep -E "error|warn" app.log`
- `grep -v "^#" .env`

## 配合使用
- `ps aux | grep nginx`
- `cat file | grep -n "pattern"`
