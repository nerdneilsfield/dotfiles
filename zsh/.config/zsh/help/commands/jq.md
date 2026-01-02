# jq

JSON 处理。

## 常用命令
- `jq . file.json`
- `jq '.items[] | .name' file.json`
- `jq -r '.items[].id' file.json`

## 常用参数
- `-r` 原始输出
- `-c` 紧凑输出

## 使用案例
- `curl -s https://api.github.com/repos/owner/repo | jq -r '.stargazers_count'`

## 配合使用
- `xh GET https://example.com | jq` 
