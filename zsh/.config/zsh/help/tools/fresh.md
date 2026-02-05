# fresh

终端文本编辑器（非模式化，偏 GUI 体验）。

## 常用命令
- `fresh file` 打开文件
- `fresh dir` 打开目录
- `fresh --help`
- `fresh --version`

## 说明
- 支持菜单、命令面板、鼠标操作
- 内置 LSP 与插件系统

## 使用案例
- `fresh file`
- `fresh dir`
- `fresh --help`

## 配合使用
- `rg --files | fzf --bind 'enter:execute(fresh {})'`

## 参考
- https://github.com/sinelaw/fresh
