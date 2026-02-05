# scp

安全拷贝文件。

## 常用命令
- `scp file user@host:/path/`
- `scp -r dir user@host:/path/`
- `scp user@host:/path/file .`

## 常用参数
- `-r` 递归
- `-P` 端口
- `-i` 私钥

## 使用案例
- `scp -P 2222 file user@host:/tmp/`

## 配合使用
- `tar -czf - dir | ssh user@host "cat > dir.tar.gz"`
