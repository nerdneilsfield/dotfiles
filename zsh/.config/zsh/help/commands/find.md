# find

文件查找。

## 常用命令
- `find . -type f`
- `find . -type f -name "*.md"`
- `find . -type d -maxdepth 2`
- `find . -type f -mtime -1`

## 常用参数
- `-type` f/d/l
- `-name` 名称匹配
- `-maxdepth/-mindepth` 深度
- `-mtime` 修改时间
- `-size` 文件大小
- `-exec` 执行命令

## 使用案例
- `find . -type f -name "*.log" -delete`
- `find . -type f -size +100M`
- `find . -type f -exec wc -l {} \;`

## 配合使用
- `find . -type f | fzf`
- `find . -type f -name "*.md" -print0 | xargs -0 rg "TODO"`
