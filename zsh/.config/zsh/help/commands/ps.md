# ps

查看进程。

## 常用命令
- `ps aux`
- `ps -ef`
- `ps -p PID -o pid,ppid,cmd`

## 常用参数
- `-o` 输出字段

## 使用案例
- `ps aux | rg nginx`
- `ps -ef | rg docker`

## 配合使用
- `ps aux | sort -nrk 3 | head -n 10` CPU 排序
