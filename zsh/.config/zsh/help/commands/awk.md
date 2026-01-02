# awk

文本处理与列提取。

## 常用命令
- `awk '{print $1}' file`
- `awk -F":" '{print $1,$3}' /etc/passwd`
- `awk '/pattern/ {print $0}' file`

## 常用参数
- `-F` 分隔符
- `-v` 变量

## 使用案例
- `awk -F"," '{print $1,$3}' data.csv`
- `awk '$3 > 100 {print $0}' data.txt`
- `awk '{sum+=$2} END {print sum}' data.txt`

## 配合使用
- `ps aux | awk '{print $1,$2,$11}'`
- `df -h | awk 'NR>1 {print $1,$5}'`
