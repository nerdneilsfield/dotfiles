# wget

下载工具。

## 常用命令
- `wget https://example.com/file.zip`
- `wget -O out.zip https://example.com/file.zip`

## 常用参数
- `-O` 输出文件名
- `-c` 断点续传
- `-q` 安静模式

## 使用案例
- `wget -c https://example.com/big.iso`

## 配合使用
- `wget -qO- https://example.com | rg "pattern"`
