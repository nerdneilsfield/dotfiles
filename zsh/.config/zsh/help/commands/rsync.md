# rsync

增量同步/备份。

## 常用命令
- `rsync -av src/ dest/`
- `rsync -av --delete src/ dest/`
- `rsync -avP src/ user@host:/path/`

## 常用参数
- `-a` 归档
- `-v` 详细输出
- `-P` 显示进度
- `--delete` 删除目标多余文件

## 使用案例
- `rsync -av --delete ~/src/ /mnt/backup/`
- `rsync -avP file user@host:/tmp/`

## 配合使用
- `rsync -av --exclude '.git' src/ dest/`
