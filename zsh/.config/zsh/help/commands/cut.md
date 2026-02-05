# cut

按列或字符范围切分。

## 常用命令
- `cut -d":" -f1 /etc/passwd`
- `cut -c 1-10 file`
- `cut -f1,3 -d"," file`

## 常用参数
- `-d` 分隔符
- `-f` 字段
- `-c` 字符范围

## 使用案例
- `cut -d":" -f1 /etc/passwd`
- `cut -c 1-20 file`

## 配合使用
- `rg "pattern" file | cut -d":" -f1,2`
