# just

任务运行器 (Justfile)。

## 常用命令
- `just`
- `just -l` 列出任务
- `just task` 运行任务
- `just -f path/to/justfile` 指定文件
- `just --choose` 交互选择

## 常用参数
- `-l/--list` 列表
- `-s/--summary` 简要列表
- `-f/--justfile` 指定 Justfile
- `--show` 打印任务
- `--dump` 导出解析后的 Justfile
- `--dry-run` 预演

## 使用案例
- `just -l`
- `just build`
- `just -f path/to/Justfile test`

## 配合使用
- `rg "^\w+:" Justfile | fzf` 快速找任务

## 参考
- https://github.com/casey/just
