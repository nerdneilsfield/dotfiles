# 媒体

下载、转码和截取。命令都在 `tools.zsh` 里。下载需要 `yt-dlp` 和 `ffmpeg`，图片转换需要 `magick`。

每条命令不带参数会在 stderr 打一行用法；`-h` 打完整说明。

## 下载

视频默认内嵌中文和英文自己的字幕（含自动字幕）、封面和章节，容器是 mp4。能直接复制就复制，复制失败再用 ffmpeg 重编码。URL 后面的参数原样传给 yt-dlp，后写的 `--sub-langs` 和 `-S` 盖过默认值。

字幕只收语言标签本身，例如 `zh`、`zh-Hans`、`zh-Hant`、`zh-CN`、`en`、`en-US`。不收 YouTube 翻译轨（`zh-Hans-zh-Hans`、`en-zh-Hans`），那些连续请求会 429，并让整次下载中断。

- `ytdl <url>...` 最高清视频加声音
- `ytdl-720 <url>...` 不超过 720p，竖屏按短边
- `ytdl-1080 <url>...` 不超过 1080p，竖屏按短边
- `ytdl-mp3 <url>...` 只提取音频，mp3，VBR 质量 0

```zsh
ytdl-1080 'https://www.youtube.com/watch?v=...'
ytdl-1080 URL --sub-langs en
ytdl-mp3 URL
```

## 转码

输出放在输入旁边，只换扩展名。已有同名文件会拒绝，除非加 `-f`。`-q` 改质量。`--` 后面的参数传给 ffmpeg 或 magick，放在输出文件名前面，后写的同类参数盖过 `-q`。

- `mp4-to-mp3 [-q 0-9] [-f] [-- ffmpeg 参数] <file>...` 抽出音频。默认 `-q:a 0`（0 最好，9 最小），输出 `原名.mp3`
- `png-to-jpg [-q 0-100] [-f] [-- magick 参数] <file>...` 默认质量 90
- `png-to-webp [-q 0-100] [-f] [-- magick 参数] <file>...` 默认质量 80
- `jpg-to-png [-q 0-100] [-f] [-- magick 参数] <file>...` 默认不传质量

```zsh
mp4-to-mp3 -q 4 video.mp4 -- -ar 44100
png-to-jpg -q 80 shot.png -- -resize 50%
```

输入不限扩展名，对应工具能读即可。

## 截取

`-s` 是起点，默认 0。`-t` 是时长，不写就一直到结尾。时间可以写 `90` 或 `00:01:30`。`-f` 和 `--` 的规则与转码相同。

- `mp4-cut [-s 起点] [-t 时长] [-f] [-- ffmpeg 参数] <file>...` 默认 `-c copy`，切点落在关键帧上，时长可能比 `-t` 稍长。输出 `原名-cut.原扩展名`
- `mp3-cut [-s 起点] [-t 时长] [-q 0-9] [-f] [-- ffmpeg 参数] <file>...` 重新编码成 mp3，默认 `-q:a 0`。输出 `原名-cut.mp3`
- `mp4-to-gif [-s 起点] [-t 时长] [-r 帧率] [-w 宽度] [-f] [-- ffmpeg 参数] <file>...` 默认前 5 秒、10 帧、宽 480，高度按比例，不要声音。输出 `原名.gif`。帧率 1–60，宽度 2–1920

```zsh
mp4-cut -s 00:01:30 -t 10 video.mp4
mp3-cut -s 5 -t 15 talk.mp4
mp4-to-gif -s 3 -t 4 -w 320 video.mp4
```
