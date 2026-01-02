# sort

排序文本。

## 常用命令
- `sort file`
- `sort -r file`
- `sort -n file`
- `sort -u file`

## 常用参数
- `-r` 逆序
- `-n` 数字排序
- `-u` 去重
- `-k` 指定列
- `-t` 分隔符

## 使用案例
- `sort -t":" -k2,2 file`
- `sort -nr numbers.txt | head -n 10`

## 配合使用
- `cat file | sort | uniq -c | sort -nr`
