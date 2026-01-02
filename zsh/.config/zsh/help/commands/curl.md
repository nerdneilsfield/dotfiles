# curl

HTTP 客户端。

## 常用命令
- `curl https://example.com`
- `curl -I https://example.com`
- `curl -X POST -H 'Content-Type: application/json' -d '{}' https://example.com`

## 常用参数
- `-I` 仅头部
- `-L` 跟随重定向
- `-H` 头部
- `-d` 请求体

## 使用案例
- `curl -s https://example.com | jq`
- `curl -L -o file.zip https://example.com/file.zip`

## 配合使用
- `curl -s https://example.com | rg "pattern"`
