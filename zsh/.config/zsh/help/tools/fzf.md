# fzf

模糊搜索选择器。

## 常用命令
- `fzf`
- `rg --files | fzf`
- `fzf --preview 'bat --style=numbers --color=always {}'`

## 常用参数
- `--preview` 预览
- `--preview-window` 预览布局
- `--height` 高度
- `--layout` 布局
- `-m/--multi` 多选
- `--bind` 键位绑定

## 使用案例
- `git status -s | fzf` 从改动列表中挑一个
- `rg --files -g "*.md" | fzf` 只在 Markdown 中选择
- `fd -t f | fzf` 结合 fd 快速选文件
- `fzf --preview 'rg --context 3 {}'` 预览文件内容
- `fzf --bind 'enter:execute(nvim {})'` 选中后打开

## 配合使用
- `rg --files | fzf --preview 'bat --style=numbers --color=always {}'`
- `fd -t f -e rs | fzf --preview 'bat --style=numbers --color=always {}'`
- `rg "TODO" -l | fzf` 从包含关键词的文件里选

## 参考
- https://github.com/junegunn/fzf
