# tee

同时输出到屏幕和文件。

## 常用命令
- `cmd | tee output.txt`
- `cmd | tee -a output.txt`

## 常用参数
- `-a` 追加

## 使用案例
- `rg "ERROR" app.log | tee errors.txt`

## 配合使用
- `cmd | tee file | rg "pattern"`
