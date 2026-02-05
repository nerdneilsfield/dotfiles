# curlie

curl + httpie 风格。

## 常用命令
- `curlie https://example.com`
- `curlie POST https://example.com key==value`
- `curlie -X PUT https://example.com key=value`
- `curlie --help`

## 常用参数
- `-X` 方法
- `-H` 头部
- `-d` 请求体

## 使用案例
- `curlie https://example.com`
- `curlie POST https://example.com key==value`
- `curlie -X PUT https://example.com key=value`

## 配合使用
- `curlie https://example.com | jq`

## 参考
- https://github.com/rs/curlie
