# kill

结束进程。

## 常用命令
- `kill PID`
- `kill -9 PID`
- `kill -HUP PID`

## 常用参数
- `-9` 强制结束
- `-HUP` 重新加载

## 使用案例
- `kill -HUP $(pgrep nginx)`

## 配合使用
- `ps aux | rg app | awk '{print $2}' | xargs kill`
