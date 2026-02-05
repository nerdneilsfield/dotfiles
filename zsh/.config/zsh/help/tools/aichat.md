# aichat

命令行 AI 助手，支持 CMD/REPL、文件输入与本地服务。

## 常用命令
- `aichat "prompt"` CMD 模式
- `aichat` 进入 REPL
- `cat file | aichat` 从 stdin 输入
- `aichat -f file -f dir -- "prompt"` 传入文件/目录
- `aichat --serve` 启动本地 API 服务
- `aichat --help`

## 使用提示
- 支持多模型/多厂商
- 支持 RAG、工具调用、Agent

## 使用案例
- `aichat "prompt"`
- `aichat` 进入 REPL
- `cat file | aichat`
- `aichat -f file -f dir -- "prompt"`
- `aichat --serve`

## 配合使用
- `git diff | aichat` 让模型解读改动

## 参考
- https://github.com/sigoden/aichat
