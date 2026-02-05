# chmod

修改权限。

## 常用命令
- `chmod 644 file`
- `chmod 755 dir`
- `chmod -R 755 dir`

## 常用参数
- `-R` 递归

## 使用案例
- `chmod +x script.sh`
- `chmod -R u+rwX,g+rX,o-rwx dir`

## 配合使用
- `find . -type f -name "*.sh" -exec chmod +x {} \;`
