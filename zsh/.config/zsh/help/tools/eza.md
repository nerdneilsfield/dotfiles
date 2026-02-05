# eza

现代版 ls。

## 常用命令
- `eza`
- `eza -la`
- `eza --tree -L 2`
- `eza --git -l`

## 常用参数
- `-a` 包含隐藏文件
- `-l` 长格式
- `-T/--tree` 树形
- `-L` 递归深度
- `--icons` 图标
- `--git` 显示 git 状态
- `--group-directories-first` 目录优先
- `--sort` 排序字段

## 使用案例
- `eza -la --git` 常规查看 + git 状态
- `eza --tree -L 2` 递归两层
- `eza -la --sort=modified` 按修改时间排序
- `eza -la --group-directories-first` 目录优先

## 配合使用
- `eza -la --git | rg \"M\"` 筛出变更文件
- `eza --tree -L 2 | fzf` 树形结果中筛选

## 参考
- https://github.com/eza-community/eza
