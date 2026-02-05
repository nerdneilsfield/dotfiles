# tail

查看文件结尾/跟随。

## 常用命令
- `tail file`
- `tail -n 50 file`
- `tail -f file`

## 常用参数
- `-n` 行数
- `-f` 追踪追加

## 使用案例
- `tail -f /var/log/syslog`

## 配合使用
- `tail -f app.log | rg "ERROR"`
