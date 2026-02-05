# ssh

远程登录。

## 常用命令
- `ssh user@host`
- `ssh -p 2222 user@host`
- `ssh -i ~/.ssh/id_ed25519 user@host`

## 常用参数
- `-p` 端口
- `-i` 私钥
- `-L` 本地端口转发
- `-R` 远程端口转发

## 使用案例
- `ssh -L 8080:localhost:8080 user@host`
- `ssh -R 9000:localhost:9000 user@host`

## 配合使用
- `ssh user@host "rg 'ERROR' /var/log/app.log"`
