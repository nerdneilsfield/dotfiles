# tr

字符替换/删除。

## 常用命令
- `tr 'a-z' 'A-Z'`
- `tr -d '\r'`
- `tr -s ' '`

## 常用参数
- `-d` 删除字符
- `-s` 压缩重复字符

## 使用案例
- `cat file | tr -d '\r'`
- `echo "a  b" | tr -s ' '`

## 配合使用
- `rg "pattern" file | tr -s ' '`
