# Neovim 的 help 文档

## AstroNvim V6 自定义快捷键

当前 AstroNvim 配置使用 `Space` 作为 `<Leader>`。

### 启动

- `nvim-astro` - 使用 `NVIM_APPNAME=AstroNvim` 启动 AstroNvim
- `nv` - `nvim-astro` 的短别名

### 快捷键总览

- `<Leader><Space>` - 打开 keymap/picker 总览
- `<C-s>` - 保存当前文件
- `<Leader>fs` - 强制保存当前文件

### AI

- `<Leader>a` - AI 快捷键分组
- `<Leader>ac` - 打开或关闭 Codex popup
- `<Leader>co` - 打开或关闭 Codex popup（兼容旧入口）
- `<Leader>aC` - 打开或关闭 `codex` CLI 终端
- `<Leader>aa` - 普通模式打开或关闭 `aichat` 终端
- `<Leader>ta` - 打开或关闭 `aichat` 终端（兼容旧入口）
- `<Leader>ag` - 打开或关闭 `gemini` CLI 终端
- `<Leader>al` - 打开或关闭 `claude` CLI 终端
- `<Leader>ao` - 打开或关闭 `opencode` 终端
- `<Leader>aq` - 打开或关闭 `qwen` CLI 终端
- `<Leader>ah` - 打开或关闭 CodeCompanion chat
- `<Leader>ai` - 打开 CodeCompanion inline assistant
- `<Leader>ap` - 打开 CodeCompanion actions
- 视觉模式 `<Leader>aa` - 将选区加入 CodeCompanion chat
- 视觉模式 `<Leader>ah` - 打开或关闭 CodeCompanion chat
- 视觉模式 `<Leader>ai` - 对选区使用 CodeCompanion inline assistant
- 视觉模式 `<Leader>ap` - 对选区打开 CodeCompanion actions

AI CLI 入口会先检查对应命令是否存在；没有安装时会显示提示，不会打开失败终端。

### 跳转

- `<Leader>j` - Jump 快捷键分组
- `<Leader>ja` - Flash jump
- `<Leader>jj` - Flash jump
- `<Leader>jt` - Flash Treesitter
- `<Leader>js` - 跳转到当前 buffer 的符号列表

### Buffer 和标签页

- `<Leader>bn` - 新建标签页
- `<Leader>bD` - 选择 buffer 并关闭
- `<Leader>bQ` - 强制关闭当前 buffer

### 窗口

- `<Leader>w` - Window 快捷键分组
- `<Leader>wh` - 切到左侧窗口
- `<Leader>wl` - 切到右侧窗口
- `<Leader>wj` - 切到下方窗口
- `<Leader>wk` - 切到上方窗口
- `<Leader>wv` - 垂直分屏
- `<Leader>ws` - 水平分屏
- `<Leader>wq` - 关闭当前窗口
- `<Leader>wm` - 只保留当前窗口
- `<Leader>wt` - 切换 Trouble diagnostics
- `<Leader>wu` - 切换 Undotree

### 删除文本

- `<Leader>dd` - Delete 快捷键分组
- `<Leader>ddd` - 删除当前行
- `<Leader>ddp` - 删除当前段落
- `<Leader>ddP` - 删除到下一个段落边界
- `<Leader>dda` - 删除整个文件
- `<Leader>ddb` - 删除双引号内文本
