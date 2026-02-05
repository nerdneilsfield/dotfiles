# shell loops (for/while)

常用 shell 循环。

## for
- `for f in *.log; do echo "$f"; done`
- `for i in {1..5}; do echo $i; done`

## while
- `while read -r line; do echo "$line"; done < file`
- `cmd | while read -r line; do echo "$line"; done`

## 使用案例
- `for f in $(rg --files -g "*.md"); do wc -l "$f"; done`
- `find . -type f | while read -r f; do echo "$f"; done`

## 配合使用
- `rg --files | while read -r f; do rg "TODO" "$f"; done`
