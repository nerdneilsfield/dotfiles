# delta

更好看的 diff。

## 常用命令
- `git diff | delta`
- `delta file1 file2`

## 常用参数
- `--side-by-side` 并排视图
- `--line-numbers` 行号
- `--syntax-theme` 主题

## 配置
- `~/.gitconfig` 中配置 `core.pager` 或 `delta`

## 使用案例
- `git diff | delta`
- `git show | delta`
- `delta file1 file2`

## 配合使用
- `git log -p | delta`

## 参考
- https://github.com/dandavison/delta
