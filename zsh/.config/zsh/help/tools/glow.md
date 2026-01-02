# glow

终端渲染 Markdown。

## 常用命令
- `glow README.md`
- `glow .` (递归发现 Markdown)
- `glow https://example.com/README.md`
- `glow --help`
- `glow --version`

## 使用提示
- 适合在终端里快速预览文档
- 支持本地文件、目录和 URL

## 使用案例
- `glow README.md`
- `glow docs/`
- `glow https://example.com/README.md`

## 配合使用
- `rg --files -g "*.md" | fzf --preview 'glow {}'`

## 参考
- https://github.com/charmbracelet/glow
