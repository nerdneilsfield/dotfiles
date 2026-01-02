# xargs

把标准输入转换为命令参数。

## 常用命令
- `echo a b c | xargs echo`
- `printf '%s\n' *.log | xargs rm`
- `printf '%s\0' *.log | xargs -0 rm`

## 常用参数
- `-n` 每次取 N 个参数
- `-P` 并行数
- `-0` 使用 NUL 分隔

## 使用案例
- `rg -l "TODO" | xargs sed -n '1,5p'`
- `find . -type f -print0 | xargs -0 wc -l`

## 配合使用
- `rg --files | xargs -I{} rg "pattern" {}`
