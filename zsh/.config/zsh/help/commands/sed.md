# sed

流式文本替换。

## 常用命令
- `sed 's/foo/bar/' file`
- `sed 's/foo/bar/g' file`
- `sed -n '1,10p' file`
- `sed -n '/start/,/end/p' file`

## 常用参数
- `-n` 仅输出匹配的行
- `-i` 就地替换
- `-E` 扩展正则

## 使用案例
- `sed -n '1,5p' file`
- `sed -E 's/[0-9]+/NUM/g' file`
- `sed -i 's/foo/bar/g' file` (谨慎)

## 配合使用
- `rg "pattern" -n file | sed 's/:/ -> /'`
