# Vim 9 兼容·单文件高性能配置 —— 使用说明

> 文件：`vimrc.v9_compat.opt.vim`（拷贝即用，零依赖）
> 适用：Vim 8.1+/Vim 9（不同构建自动降级以避免报错）

---

## 一、快速开始（2 步）
1. **备份当前配置**：`cp ~/.vimrc ~/.vimrc.bak 2>/dev/null || true`
2. **替换并试跑**：
   ```bash
   cp vimrc.v9_compat.opt.vim ~/.vimrc
   vim -Nu ~/.vimrc +q
   ```

若能正常退出，无报错即可日常使用。

---

## 二、这份配置帮你做了什么？（面向新用户）
- **开箱即用又不容易卡**：打开大文件会自动“降档”，避免无意义卡顿。
- **查找/替换更直观**：输入 `:%s/旧/新/` 时会**即时预览**替换效果（不真正修改）。
- **对比更清晰**：`vim -d a b` 时，尽可能使用更聪明的对齐策略。
- **省心的小功能**：保存时自动删行尾空格、再次打开文件自动回到上次位置。
- **系统剪贴板**：支持时自动启用，可直接与系统复制/粘贴互通。
- **更稳的兼容策略**：对可能报错的选项（如 `shada/laststatus/diffopt`）做了“有则用、无则跳过”。

---

## 三、常见任务 · 怎么做？

### 1) 注释/反注释代码
- **单行**：`gcc`
- **选区**：可视模式选择后按 `gc`
- **一段/一个动作**：`gc` + 动作（如 `gcap` 注释段落）
> 注：依赖你配置里内嵌的 commentary 片段；若按键不生效，用 `:verbose map gcc` 检查冲突。

### 2) 全局查找（ripgrep 优先）
- **搜索光标处单词**：`<leader>gg`（若配置中存在；否则用 `:grep 关键字`）
- **查看结果**：`:copen` 打开 Quickfix，`<Enter>` 跳转，`:cclose` 关闭。

### 3) 查找并替换（可预览）
```vim
:%s/old/new/g       " 整个文件替换
:'<,'>s/old/new/g   " 仅替换选区
```
输入时会**即时预览**（已启用 `inccommand=nosplit` 时）。

### 4) Diff 对比
```bash
vim -d file1 file2               # 启动即进入对比
```
更好的对齐 heuristics 会尽量让改动块更“像人写的差异”。

### 5) 快速去掉“搜索高亮”
- `, <Space>`（若配置中存在）；或直接 `:nohlsearch`。

### 6) 重新打开文件回到上次编辑位置
- 无需任何操作，配置已自动记忆上次光标。

---

## 四、键位速查
- **Leader 键**：`\<Space>`（可在脚本中搜索 `mapleader` 修改）

| 模式 | 按键 | 用途（简述） | 执行（原始命令） |
|---|---|---|---|
| All | `<silent><space>tl` | :call g:ToggleNuMode()<CR> | `:call g:ToggleNuMode()<CR>` |
| Insert | `<C-h>` | <left> | `<left>` |
| Insert | `<C-j>` | <down> | `<down>` |
| Insert | `<C-k>` | <up> | `<up>` |
| Insert | `<C-l>` | <right> | `<right>` |
| Insert | `<c-_>` | <c-k> | `<c-k>` |
| Insert | `<c-a>` | <home> | `<home>` |
| Insert | `<c-d>` | <del> | `<del>` |
| Insert | `<c-e>` | <end> | `<end>` |
| Insert | `<m-H>` | <esc><c-w>h | `<esc><c-w>h` |
| Insert | `<m-J>` | <esc><c-w>j | `<esc><c-w>j` |
| Insert | `<m-K>` | <esc><c-w>k | `<esc><c-w>k` |
| Insert | `<m-L>` | <esc><c-w>l | `<esc><c-w>l` |
| Insert | `<m-h>` | <c-left> | `<c-left>` |
| Insert | `<m-j>` | <c-\><c-o>gj | `<c-\><c-o>gj` |
| Insert | `<m-k>` | <c-\><c-o>gk | `<c-\><c-o>gk` |
| Insert | `<m-l>` | <c-right> | `<c-right>` |
| Insert | `<m-y>` | <c-\><c-o>d$ | `<c-\><c-o>d$` |
| Insert | `<silent><d-0>` | <ESC>:tabn 10<cr> | `<ESC>:tabn 10<cr>` |
| Insert | `<silent><d-1>` | <ESC>:tabn 1<cr> | `<ESC>:tabn 1<cr>` |
| Insert | `<silent><d-2>` | <ESC>:tabn 2<cr> | `<ESC>:tabn 2<cr>` |
| Insert | `<silent><d-3>` | <ESC>:tabn 3<cr> | `<ESC>:tabn 3<cr>` |
| Insert | `<silent><d-4>` | <ESC>:tabn 4<cr> | `<ESC>:tabn 4<cr>` |
| Insert | `<silent><d-5>` | <ESC>:tabn 5<cr> | `<ESC>:tabn 5<cr>` |
| Insert | `<silent><d-6>` | <ESC>:tabn 6<cr> | `<ESC>:tabn 6<cr>` |
| Insert | `<silent><d-7>` | <ESC>:tabn 7<cr> | `<ESC>:tabn 7<cr>` |
| Insert | `<silent><d-8>` | <ESC>:tabn 8<cr> | `<ESC>:tabn 8<cr>` |
| Insert | `<silent><d-9>` | <ESC>:tabn 9<cr> | `<ESC>:tabn 9<cr>` |
| Insert | `<silent><m-0>` | <ESC>:tabn 10<cr> | `<ESC>:tabn 10<cr>` |
| Insert | `<silent><m-1>` | <ESC>:tabn 1<cr> | `<ESC>:tabn 1<cr>` |
| Insert | `<silent><m-2>` | <ESC>:tabn 2<cr> | `<ESC>:tabn 2<cr>` |
| Insert | `<silent><m-3>` | <ESC>:tabn 3<cr> | `<ESC>:tabn 3<cr>` |
| Insert | `<silent><m-4>` | <ESC>:tabn 4<cr> | `<ESC>:tabn 4<cr>` |
| Insert | `<silent><m-5>` | <ESC>:tabn 5<cr> | `<ESC>:tabn 5<cr>` |
| Insert | `<silent><m-6>` | <ESC>:tabn 6<cr> | `<ESC>:tabn 6<cr>` |
| Insert | `<silent><m-7>` | <ESC>:tabn 7<cr> | `<ESC>:tabn 7<cr>` |
| Insert | `<silent><m-8>` | <ESC>:tabn 8<cr> | `<ESC>:tabn 8<cr>` |
| Insert | `<silent><m-9>` | <ESC>:tabn 9<cr> | `<ESC>:tabn 9<cr>` |
| Insert | `jk` | <Esc> | `<Esc>` |
| Normal | `<C-h>` | <left> | `<left>` |
| Normal | `<C-j>` | <down> | `<down>` |
| Normal | `<C-k>` | <up> | `<up>` |
| Normal | `<C-l>` | <right> | `<right>` |
| Normal | `<c-j>` | jjj | `jjj` |
| Normal | `<c-k>` | kkk | `kkk` |
| Normal | `<expr>` | 注释/反注释 | `<Plug>Commentary     <SID>go()` |
| Normal | `<expr>` | 注释/反注释 | `<Plug>CommentaryLine <SID>go() . '_'` |
| Normal | `<m-H>` | <c-w>h | `<c-w>h` |
| Normal | `<m-J>` | <c-w>j | `<c-w>j` |
| Normal | `<m-K>` | <c-w>k | `<c-w>k` |
| Normal | `<m-L>` | <c-w>l | `<c-w>l` |
| Normal | `<m-h>` | b | `b` |
| Normal | `<m-j>` | gj | `gj` |
| Normal | `<m-k>` | gk | `gk` |
| Normal | `<m-l>` | w | `w` |
| Normal | `<m-y>` | d$ | `d$` |
| Normal | `<silent>` | <leader>bn :bn<cr> | `<leader>bn :bn<cr>` |
| Normal | `<silent>` | <leader>bp :bp<cr> | `<leader>bp :bp<cr>` |
| Normal | `<silent>` | <leader>tc :tabnew<cr> | `<leader>tc :tabnew<cr>` |
| Normal | `<silent>` | <leader>tq :tabclose<cr> | `<leader>tq :tabclose<cr>` |
| Normal | `<silent>` | <leader>tn :tabnext<cr> | `<leader>tn :tabnext<cr>` |
| Normal | `<silent>` | <leader>tp :tabprev<cr> | `<leader>tp :tabprev<cr>` |
| Normal | `<silent>` | <leader>to :tabonly<cr> | `<leader>to :tabonly<cr>` |
| Normal | `<silent>` | <space><tab>n :tabnew<cr> | `<space><tab>n :tabnew<cr>` |
| Normal | `<silent>` | <space><tab>[ :tabprev<cr> | `<space><tab>[ :tabprev<cr>` |
| Normal | `<silent>` | <space><tab>] :tabnext<cr> | `<space><tab>] :tabnext<cr>` |
| Normal | `<silent>` | <space><tab><tab> :tabnext<cr> | `<space><tab><tab> :tabnext<cr>` |
| Normal | `<silent>` | <space><tab>. :tabprev<cr> | `<space><tab>. :tabprev<cr>` |
| Normal | `<silent>` | <space><tab>x :tabclose<cr> | `<space><tab>x :tabclose<cr>` |
| Normal | `<silent>` | <space><tab>q :tabclose<cr> | `<space><tab>q :tabclose<cr>` |
| Normal | `<silent>` | <space><tab>o :tabonly<cr> | `<space><tab>o :tabonly<cr>` |
| Normal | `<silent>` | <Plug>ChangeCommentary c:<C-U>call <SID>textobject(1)<CR> | `<Plug>ChangeCommentary c:<C-U>call <SID>textobject(1)<CR>` |
| Normal | `<silent>` | 注释/反注释 | `<Plug>CommentaryUndo :echoerr` |
| Normal | `<silent><d-0>` | :tabn 10<cr> | `:tabn 10<cr>` |
| Normal | `<silent><d-1>` | :tabn 1<cr> | `:tabn 1<cr>` |
| Normal | `<silent><d-2>` | :tabn 2<cr> | `:tabn 2<cr>` |
| Normal | `<silent><d-3>` | :tabn 3<cr> | `:tabn 3<cr>` |
| Normal | `<silent><d-4>` | :tabn 4<cr> | `:tabn 4<cr>` |
| Normal | `<silent><d-5>` | :tabn 5<cr> | `:tabn 5<cr>` |
| Normal | `<silent><d-6>` | :tabn 6<cr> | `:tabn 6<cr>` |
| Normal | `<silent><d-7>` | :tabn 7<cr> | `:tabn 7<cr>` |
| Normal | `<silent><d-8>` | :tabn 8<cr> | `:tabn 8<cr>` |
| Normal | `<silent><d-9>` | :tabn 9<cr> | `:tabn 9<cr>` |
| Normal | `<silent><leader>0` | 10gt<cr> | `10gt<cr>` |
| Normal | `<silent><leader>1` | 1gt<cr> | `1gt<cr>` |
| Normal | `<silent><leader>2` | 2gt<cr> | `2gt<cr>` |
| Normal | `<silent><leader>3` | 3gt<cr> | `3gt<cr>` |
| Normal | `<silent><leader>4` | 4gt<cr> | `4gt<cr>` |
| Normal | `<silent><leader>5` | 5gt<cr> | `5gt<cr>` |
| Normal | `<silent><leader>6` | 6gt<cr> | `6gt<cr>` |
| Normal | `<silent><leader>7` | 7gt<cr> | `7gt<cr>` |
| Normal | `<silent><leader>8` | 8gt<cr> | `8gt<cr>` |
| Normal | `<silent><leader>9` | 9gt<cr> | `9gt<cr>` |
| Normal | `<silent><leader>tl` | :call Tab_MoveLeft()<cr> | `:call Tab_MoveLeft()<cr>` |
| Normal | `<silent><leader>tr` | :call Tab_MoveRight()<cr> | `:call Tab_MoveRight()<cr>` |
| Normal | `<silent><m-0>` | :tabn 10<cr> | `:tabn 10<cr>` |
| Normal | `<silent><m-1>` | :tabn 1<cr> | `:tabn 1<cr>` |
| Normal | `<silent><m-2>` | :tabn 2<cr> | `:tabn 2<cr>` |
| Normal | `<silent><m-3>` | :tabn 3<cr> | `:tabn 3<cr>` |
| Normal | `<silent><m-4>` | :tabn 4<cr> | `:tabn 4<cr>` |
| Normal | `<silent><m-5>` | :tabn 5<cr> | `:tabn 5<cr>` |
| Normal | `<silent><m-6>` | :tabn 6<cr> | `:tabn 6<cr>` |
| Normal | `<silent><m-7>` | :tabn 7<cr> | `:tabn 7<cr>` |
| Normal | `<silent><m-8>` | :tabn 8<cr> | `:tabn 8<cr>` |
| Normal | `<silent><m-9>` | :tabn 9<cr> | `:tabn 9<cr>` |
| Normal | `<silent><m-left>` | :call Tab_MoveLeft()<cr> | `:call Tab_MoveLeft()<cr>` |
| Normal | `<silent><m-right>` | :call Tab_MoveRight()<cr> | `:call Tab_MoveRight()<cr>` |
| Normal | `<silent><space>bD` | :bd!<cr> | `:bd!<cr>` |
| Normal | `<silent><space>bb` | :ls<cr>:b<space> | `:ls<cr>:b<space>` |
| Normal | `<silent><space>bd` | :bd<cr> | `:bd<cr>` |
| Normal | `<silent><space>bk` | :bwipeout<cr> | `:bwipeout<cr>` |
| Normal | `<silent><space>bn` | :bnext<cr> | `:bnext<cr>` |
| Normal | `<silent><space>bp` | :bprev<cr> | `:bprev<cr>` |
| Normal | `<silent><space>f*` | :AsyncRun! -cwd=<root> rg -n --no-heading | `:AsyncRun! -cwd=<root> rg -n --no-heading` |
| Normal | `<silent><space>f*` | :AsyncRun! -cwd=<root> findstr /n /s /C: | `:AsyncRun! -cwd=<root> findstr /n /s /C:` |
| Normal | `<silent><space>f*` | :AsyncRun! -cwd=<root> grep -n -s -R <C-R><C-W> | `:AsyncRun! -cwd=<root> grep -n -s -R <C-R><C-W>` |
| Normal | `<silent><space>fS` | :saveas | `:saveas` |
| Normal | `<silent><space>feR` | :source ~/.vimrc<cr> | `:source ~/.vimrc<cr>` |
| Normal | `<silent><space>fed` | :e ~/.vimrc<cr> | `:e ~/.vimrc<cr>` |
| Normal | `<silent><space>fs` | 保存当前缓冲区 | `:update<CR>` |
| Normal | `<silent><space>lD` |  | `` |
| Normal | `<silent><space>ld` |  | `` |
| Normal | `<silent><space>lp` | p | `p` |
| Normal | `<silent><space>ly` | yy | `yy` |
| Normal | `<silent><space>p` |  | `` |
| Normal | `<silent><space>sc` | 清除搜索高亮 | `:nohlsearch<cr>` |
| Normal | `<silent><space>ss` | :set hlsearch!<cr> | `:set hlsearch!<cr>` |
| Normal | `<silent><space>t<c-d>` | :set background=dark <cr> | `:set background=dark <cr>` |
| Normal | `<silent><space>t<c-l>` | :set background=light <cr> | `:set background=light <cr>` |
| Normal | `<silent><space>tm` | :call ToggleMouse()<cr> | `:call ToggleMouse()<cr>` |
| Normal | `<silent><space>wq` | <c-w>q | `<c-w>q` |
| Normal | `<silent><space>ws` | :<c-U>split<cr> | `:<c-U>split<cr>` |
| Normal | `<silent><space>wv` | :<c-U>vsplit<cr> | `:<c-U>vsplit<cr>` |
| Normal | `<silent><space>zM` | zM | `zM` |
| Normal | `<silent><space>zR` | zR | `zR` |
| Normal | `<silent><space>za` | za | `za` |
| Normal | `<silent><space>zc` | zc | `zc` |
| Normal | `<silent><space>zo` | zo | `zo` |
| Normal | `<space>sr` | :%s/\<光标词\>//g<Left><Left> | `:%s/\<<C-r><C-w>\>//g<Left><Left>` |
| Normal | `<space>w+` | <c-w>+ | `<c-w>+` |
| Normal | `<space>w-` | <c-w>- | `<c-w>-` |
| Normal | `<space>w<` | <c-w>< | `<c-w><` |
| Normal | `<space>w=` | <c-w>= | `<c-w>=` |
| Normal | `<space>w>` | <c-w>> | `<c-w>>` |
| Normal | `<space>wh` | <c-w>h | `<c-w>h` |
| Normal | `<space>wj` | <c-w>j | `<c-w>j` |
| Normal | `<space>wk` | <c-w>k | `<c-w>k` |
| Normal | `<space>wl` | <c-w>l | `<c-w>l` |
| Normal | `<space>wo` | <c-w>o | `<c-w>o` |
| Normal | `gc` | 按动作/选区注释/反注释 | `<Plug>Commentary` |
| Normal | `gcc` | 注释/反注释当前行 | `<Plug>CommentaryLine` |
| Normal | `gcu` | 按动作/选区注释/反注释 | `<Plug>Commentary<Plug>Commentary` |
| Operator | `<silent>` | 注释/反注释 | `<Plug>Commentary        :<C-U>call <SID>textobject(get(v:, 'operator', '') ==# 'c')<CR>` |
| Operator | `gc` | 按动作/选区注释/反注释 | `<Plug>Commentary` |
| Visual | `<expr>` | 注释/反注释 | `<Plug>Commentary     <SID>go()` |
| Visual | `<silent><space>p` |  | `` |
| Visual | `<silent><space>y` |  | `` |
| Visual | `gc` | 按动作/选区注释/反注释 | `<Plug>Commentary` |


> 提示：如需查看某个按键的具体定义和来源，使用 `:verbose map <键>`（例如 `:verbose map gc`）。

---

## 五、可调选项（不改动逻辑的安全调整）
- **大文件阈值**：在脚本中的 `augroup BigFile` 里，把 `2*1024*1024` 换成你常见文件大小。
- **强制真彩色**：确定你的终端支持 True Color 时，可将 `if exists('&termguicolors')` 改为 `set termguicolors`。
- **禁用保存时去尾空格**：注释掉 `augroup TrimWS` 块。

---

## 六、故障排查（最常见）
- **报 `E474 Invalid argument`**：通常是用了当前版本不支持的参数。可将该行改为：`if exists('&该选项') | set 该选项=值 | endif`。
- **报 `E518 Unknown option: shada`**：构建缺少 `+shada`。脚本已自动回退到 `viminfo`；可用 `:version` 查看功能列表。
- **注释按键无效**：用 `:verbose map gcc` 检查是否被其他映射覆盖；或确认文件类型的 `commentstring` 是否合理。

---

## 七、为什么这份配置适合 Vim 9
- 使用 **能力探测/静默降级** 规避了 9.0 里对某些老选项/非兼容语法的严格报错。
- `diffopt`/`laststatus` 等新特性均做了条件启用；同时保持在旧版 Vim 的可用 fallback。
