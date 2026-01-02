# uniq

去重（需要已排序）。

## 常用命令
- `uniq file`
- `uniq -c file`
- `uniq -d file`

## 常用参数
- `-c` 统计次数
- `-d` 仅显示重复行
- `-u` 仅显示唯一行

## 使用案例
- `sort file | uniq -c | sort -nr`

## 配合使用
- `rg -o "pattern" file | sort | uniq -c`
