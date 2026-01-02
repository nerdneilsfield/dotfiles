# xh

更友好的 HTTP 客户端。

## 常用命令
- `xh GET https://example.com`
- `xh POST https://example.com key==value`
- `xh PUT https://example.com key=value`
- `xh -j POST https://example.com foo=bar`
- `xh --help`

## 常用参数
- `-j` JSON
- `-f` 表单
- `-v` 详细输出

## 使用案例
- `xh GET https://example.com`
- `xh POST https://example.com key==value`
- `xh PUT https://example.com key=value`
- `xh -j POST https://example.com foo=bar`

## 配合使用
- `xh GET https://example.com | jq` 结合 JSON 处理

## 参考
- https://github.com/ducaale/xh
