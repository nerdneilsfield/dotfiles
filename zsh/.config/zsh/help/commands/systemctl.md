# systemctl

systemd 服务管理。

## 常用命令
- `systemctl status service`
- `systemctl start service`
- `systemctl stop service`
- `systemctl restart service`
- `systemctl enable service`
- `systemctl disable service`

## 常用参数
- `--user` 用户服务

## 使用案例
- `systemctl status ssh`
- `systemctl restart nginx`

## 配合使用
- `systemctl list-units --type=service | rg nginx`
