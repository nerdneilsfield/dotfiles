# tar

打包/解包。

## 常用命令
- `tar -czf file.tar.gz dir/`
- `tar -xzf file.tar.gz`
- `tar -tf file.tar.gz`

## 常用参数
- `-c` 创建
- `-x` 解包
- `-t` 列表
- `-z` gzip
- `-f` 文件名

## 使用案例
- `tar -czf backup.tar.gz ~/work`
- `tar -xzf backup.tar.gz -C /tmp`

## 配合使用
- `tar -czf - dir | ssh host "cat > backup.tar.gz"`
