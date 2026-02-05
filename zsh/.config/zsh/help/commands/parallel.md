# parallel (GNU parallel)

并行执行任务。

## 常用命令
- `parallel echo ::: a b c`
- `parallel -j 4 cmd ::: a b c`
- `parallel cmd ::: file1 file2`

## 常用参数
- `-j` 并发数
- `--bar` 进度条
- `--dry-run` 预演

## 使用案例
- `parallel -j 4 rg "TODO" ::: src1 src2`
- `ls *.log | parallel -j 8 gzip {}`
- `cat urls.txt | parallel -j 8 curl -s {} > /dev/null`

## 配合使用
- `rg --files | parallel -j 4 gzip {}`
