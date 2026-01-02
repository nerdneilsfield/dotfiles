# wc

统计行/词/字节。

## 常用命令
- `wc file`
- `wc -l file`
- `wc -w file`
- `wc -c file`

## 常用参数
- `-l` 行数
- `-w` 单词数
- `-c` 字节数

## 使用案例
- `rg --files | wc -l`
- `wc -l *.md`

## 配合使用
- `find . -type f | wc -l`
