# sd

更快的 sed 替代。

## 常用命令
- `sd "from" "to" file`
- `sd -s "from" "to" file` (就地替换)
- `sd -F "from" "to"` (纯字符串)

## 常用参数
- `-s/--in-place` 就地替换
- `-F/--fixed-strings` 纯字符串
- `-p/--preview` 预览

## 使用案例
- `sd "foo" "bar" file`
- `sd -s "foo" "bar" file` 就地替换
- `sd -F "a.b" "x" file`

## 配合使用
- `rg -l "foo" | xargs sd -s "foo" "bar"`

## 参考
- https://github.com/chmln/sd
