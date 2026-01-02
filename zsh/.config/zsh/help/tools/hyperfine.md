# hyperfine

命令基准测试。

## 常用命令
- `hyperfine "cmd"`
- `hyperfine "cmd1" "cmd2"`
- `hyperfine -w 3 -r 10 "cmd"`

## 常用参数
- `-w` 预热次数
- `-r` 运行次数
- `--export-json` 导出 JSON
- `--export-markdown` 导出 Markdown

## 使用案例
- `hyperfine "cmd"`
- `hyperfine "cmd1" "cmd2"`
- `hyperfine -w 3 -r 10 "cmd"`

## 配合使用
- `hyperfine --export-markdown bench.md "cmd"`

## 参考
- https://github.com/sharkdp/hyperfine
