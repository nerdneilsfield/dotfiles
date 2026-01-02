# tmux

终端复用器。

## 常用命令
- `tmux` 新建会话
- `tmux new -s name` 新会话命名
- `tmux ls` 列出会话
- `tmux attach -t name` 附加会话
- `tmux kill-session -t name` 删除会话
- `tmux rename-session -t old new` 重命名会话
- `tmux switch -t name` 切换会话

## 常用键位（默认前缀 Ctrl+b）
- `Ctrl+b c` 新建窗口
- `Ctrl+b n` 下一个窗口
- `Ctrl+b p` 上一个窗口
- `Ctrl+b ,` 重命名窗口
- `Ctrl+b &` 关闭窗口
- `Ctrl+b l` 上一个窗口（最近使用）
- `Ctrl+b %` 垂直分屏
- `Ctrl+b "` 水平分屏
- `Ctrl+b o` 切换分屏
- `Ctrl+b x` 关闭分屏
- `Ctrl+b !` 分屏转窗口
- `Ctrl+b z` 分屏放大/还原
- `Ctrl+b q` 显示分屏编号
- `Ctrl+b t` 显示时钟
- `Ctrl+b d` 断开会话
- `Ctrl+b s` 会话列表
- `Ctrl+b w` 窗口列表
- `Ctrl+b :` 进入命令行
- `Ctrl+b [` 进入复制模式

## 使用案例
- `tmux new -s dev`
- `tmux attach -t dev`
- `tmux switch -t dev`
- `tmux kill-session -t dev`

## 复制模式（常用）
- `Ctrl+b [` 进入复制模式
- `Space` 开始选择
- `Enter` 复制并退出
- `q` 退出复制模式

## 窗口与分屏（命令）
- `tmux new-window -n name`
- `tmux split-window -h`
- `tmux split-window -v`
- `tmux select-pane -L/-R/-U/-D`

## 配合使用
- `tmux` + `zellij` 二选一即可

## 参考
- https://github.com/tmux/tmux
