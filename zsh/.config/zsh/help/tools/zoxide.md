# zoxide

智能目录跳转。

## 常用命令
- `zoxide init zsh` (写入 rc)
- `z foo` (跳转)
- `zi` (交互选择)

## 说明
- 需要在 shell 启动时初始化

## 使用案例
- `zoxide init zsh`
- `z project`
- `zi`

## 配合使用
- `fd -t d | fzf` 找目录后 `z <dir>`

## 参考
- https://github.com/ajeetdsouza/zoxide
