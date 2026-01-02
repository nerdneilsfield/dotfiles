# du

目录大小。

## 常用命令
- `du -sh dir`
- `du -h -d 1 dir`

## 常用参数
- `-s` 汇总
- `-h` 人类可读
- `-d` 深度

## 使用案例
- `du -h -d 1 . | sort -hr`

## 配合使用
- `du -h -d 1 . | head -n 10`
