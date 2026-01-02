# chown

修改属主/属组。

## 常用命令
- `chown user file`
- `chown user:group file`
- `chown -R user:group dir`

## 常用参数
- `-R` 递归

## 使用案例
- `sudo chown -R $USER:$USER ~/data`

## 配合使用
- `find /var/www -type d -exec chown user:group {} \;`
