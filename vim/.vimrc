" 防止重复加载
if get(s:, 'loaded', 0) != 0
	finish
else
	let s:loaded = 1
endif

" 取得本文件所在的目录
let s:home = fnamemodify(resolve(expand('<sfile>:p')), ':h')

" 定义一个命令用来加载文件
command! -nargs=1 LoadScript exec 'so '.s:home.'/'.'<args>'

" 将 vim-init 目录加入 runtimepath
exec 'set rtp+='.s:home

" 运行 nvm 来获得 `node`
" exec '!nvm'

" 将 ~/.vim 目录加入 runtimepath (有时候 vim 不会自动帮你加入）
set rtp+=~/.vim


" =============== BASIC =============================

"----------------------------------------------------------------------
" 基础设置
"----------------------------------------------------------------------

" 禁用 vi 兼容模式
set nocompatible

" 设置 Backspace 键模式
set bs=eol,start,indent

" 自动缩进
set autoindent

" 打开 C/C++ 语言缩进优化
set cindent

" Windows 禁用 ALT 操作菜单（使得 ALT 可以用到 Vim里）
set winaltkeys=no

" 关闭自动换行
set nowrap

" 打开功能键超时检测（终端下功能键为一串 ESC 开头的字符串）
set ttimeout

" 功能键超时检测 50 毫秒
set ttimeoutlen=50

" 显示光标位置
set ruler


"----------------------------------------------------------------------
" 搜索设置
"----------------------------------------------------------------------

" 搜索时忽略大小写
set ignorecase

" 智能搜索大小写判断，默认忽略大小写，除非搜索内容包含大写字母
set smartcase

" 高亮搜索内容
set hlsearch

" 查找输入时动态增量显示查找结果
set incsearch


"----------------------------------------------------------------------
" 编码设置
"----------------------------------------------------------------------
if has('multi_byte')
	" 内部工作编码
	set encoding=utf-8

	" 文件默认编码
	set fileencoding=utf-8

	" 打开文件时自动尝试下面顺序的编码
	set fileencodings=ucs-bom,utf-8,gbk,gb18030,big5,euc-jp,latin1
endif


"----------------------------------------------------------------------
" 允许 Vim 自带脚本根据文件类型自动设置缩进等
"----------------------------------------------------------------------
if has('autocmd')
	filetype plugin indent on
endif


"----------------------------------------------------------------------
" 语法高亮设置
"----------------------------------------------------------------------
if has('syntax')  
	syntax enable 
	syntax on 
endif


"----------------------------------------------------------------------
" 其他设置
"----------------------------------------------------------------------

" 显示匹配的括号
set showmatch

" 显示括号匹配的时间
set matchtime=2

" 显示最后一行
set display=lastline

" 允许下方显示目录
set wildmenu

" 延迟绘制（提升性能）
set lazyredraw

" 错误格式
set errorformat+=[%f:%l]\ ->\ %m,[%f:%l]:%m

" 设置分隔符可视
set listchars=tab:\|\ ,trail:.,extends:>,precedes:<


" 设置 tags：当前文件所在目录往上向根目录搜索直到碰到 .tags 文件
" 或者 Vim 当前目录包含 .tags 文件
set tags=./.tags;,.tags

" 如遇Unicode值大于255的文本，不必等到空格再折行
set formatoptions+=m

" 合并两行中文时，不在中间加空格
set formatoptions+=B

" 文件换行符，默认使用 unix 换行符
set ffs=unix,dos,mac


"----------------------------------------------------------------------
" 设置代码折叠
"----------------------------------------------------------------------
if has('folding')
	" 允许代码折叠
	set foldenable

	" 代码折叠默认使用缩进
	set fdm=indent

	" 默认打开所有缩进
	set foldlevel=99
endif


"----------------------------------------------------------------------
" 文件搜索和补全时忽略下面扩展名
"----------------------------------------------------------------------
set suffixes=.bak,~,.o,.h,.info,.swp,.obj,.pyc,.pyo,.egg-info,.class

set wildignore=*.o,*.obj,*~,*.exe,*.a,*.pdb,*.lib,*.out "stuff to ignore when tab completing
set wildignore+=*.so,*.dll,*.swp,*.egg,*.jar,*.class,*.pyc,*.pyo,*.bin,*.dex
set wildignore+=*.zip,*.7z,*.rar,*.gz,*.tar,*.gzip,*.bz2,*.tgz,*.xz    " MacOSX/Linux
set wildignore+=*DS_Store*,*.ipch
set wildignore+=*.gem
set wildignore+=*.png,*.jpg,*.gif,*.bmp,*.tga,*.pcx,*.ppm,*.img,*.iso
set wildignore+=*.so,*.swp,*.zip,*/.Trash/**,*.pdf,*.dmg,*/.rbenv/**
set wildignore+=*/.nx/**,*.app,*.git,.git
set wildignore+=*.wav,*.mp3,*.ogg,*.pcm
set wildignore+=*.mht,*.suo,*.sdf,*.jnlp
set wildignore+=*.chm,*.epub,*.pdf,*.mobi,*.ttf,*.djvu
set wildignore+=*.mp4,*.avi,*.flv,*.mov,*.mkv,*.swf,*.swc
set wildignore+=*.ppt,*.pptx,*.docx,*.xlt,*.xls,*.xlsx,*.odt,*.wps
set wildignore+=*.msi,*.crx,*.deb,*.vfd,*.apk,*.ipa,*.bin,*.msu
set wildignore+=*.gba,*.sfc,*.078,*.nds,*.smd,*.smc
set wildignore+=*.linux2,*.win32,*.darwin,*.freebsd,*.linux,*.android


" ==================== CONFIG ===============================

" vim: set ts=4 sw=4 tw=78 noet :


"----------------------------------------------------------------------
" 有 tmux 何没有的功能键超时（毫秒）
"----------------------------------------------------------------------
if $TMUX != ''
	set ttimeoutlen=30
elseif &ttimeoutlen > 80 || &ttimeoutlen <= 0
	set ttimeoutlen=80
endif


"----------------------------------------------------------------------
" 终端下允许 ALT，详见：http://www.skywind.me/blog/archives/2021
" 记得设置 ttimeout （见 init-basic.vim） 和 ttimeoutlen （上面）
"----------------------------------------------------------------------
if has('nvim') == 0 && has('gui_running') == 0
	function! s:metacode(key)
		exec "set <M-".a:key.">=\e".a:key
	endfunc
	for i in range(10)
		call s:metacode(nr2char(char2nr('0') + i))
	endfor
	for i in range(26)
		call s:metacode(nr2char(char2nr('a') + i))
		call s:metacode(nr2char(char2nr('A') + i))
	endfor
	for c in [',', '.', '/', ';', '{', '}']
		call s:metacode(c)
	endfor
	for c in ['?', ':', '-', '_', '+', '=', "'"]
		call s:metacode(c)
	endfor
endif


"----------------------------------------------------------------------
" 终端下功能键设置
"----------------------------------------------------------------------
function! s:key_escape(name, code)
	if has('nvim') == 0 && has('gui_running') == 0
		exec "set ".a:name."=\e".a:code
	endif
endfunc


"----------------------------------------------------------------------
" 功能键终端码矫正
"----------------------------------------------------------------------
call s:key_escape('<F1>', 'OP')
call s:key_escape('<F2>', 'OQ')
call s:key_escape('<F3>', 'OR')
call s:key_escape('<F4>', 'OS')
call s:key_escape('<S-F1>', '[1;2P')
call s:key_escape('<S-F2>', '[1;2Q')
call s:key_escape('<S-F3>', '[1;2R')
call s:key_escape('<S-F4>', '[1;2S')
call s:key_escape('<S-F5>', '[15;2~')
call s:key_escape('<S-F6>', '[17;2~')
call s:key_escape('<S-F7>', '[18;2~')
call s:key_escape('<S-F8>', '[19;2~')
call s:key_escape('<S-F9>', '[20;2~')
call s:key_escape('<S-F10>', '[21;2~')
call s:key_escape('<S-F11>', '[23;2~')
call s:key_escape('<S-F12>', '[24;2~')


"----------------------------------------------------------------------
" 防止tmux下vim的背景色显示异常
" Refer: http://sunaku.github.io/vim-256color-bce.html
"----------------------------------------------------------------------
if &term =~ '256color' && $TMUX != ''
	" disable Background Color Erase (BCE) so that color schemes
	" render properly when inside 256-color tmux and GNU screen.
	" see also http://snk.tuxfamily.org/log/vim-256color-bce.html
	set t_ut=
endif


"----------------------------------------------------------------------
" 备份设置
"----------------------------------------------------------------------

" 允许备份
set backup

" 保存时备份
set writebackup

" 备份文件地址，统一管理
set backupdir=~/.vim/tmp

" 备份文件扩展名
set backupext=.vim_bak

" 禁用交换文件
set noswapfile

" 禁用 undo文件
set noundofile

" 创建目录，并且忽略可能出现的警告
silent! call mkdir(expand('~/.vim/tmp'), "p", 0755)


"----------------------------------------------------------------------
" 配置微调
"----------------------------------------------------------------------

" 修正 ScureCRT/XShell 以及某些终端乱码问题，主要原因是不支持一些
" 终端控制命令，比如 cursor shaping 这类更改光标形状的 xterm 终端命令
" 会令一些支持 xterm 不完全的终端解析错误，显示为错误的字符，比如 q 字符
" 如果你确认你的终端支持，不会在一些不兼容的终端上运行该配置，可以注释
if has('nvim')
	set guicursor=
elseif (!has('gui_running')) && has('terminal') && has('patch-8.0.1200')
	let g:termcap_guicursor = &guicursor
	let g:termcap_t_RS = &t_RS
	let g:termcap_t_SH = &t_SH
	set guicursor=
	set t_RS=
	set t_SH=
endif

" 打开文件时恢复上一次光标所在位置
autocmd BufReadPost *
	\ if line("'\"") > 1 && line("'\"") <= line("$") |
	\	 exe "normal! g`\"" |
	\ endif

" 定义一个 DiffOrig 命令用于查看文件改动
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
          \ | wincmd p | diffthis
endif



"----------------------------------------------------------------------
" 文件类型微调
"----------------------------------------------------------------------
augroup InitFileTypesGroup

	" 清除同组的历史 autocommand
	au!

	" C/C++ 文件使用 // 作为注释
	au FileType c,cpp setlocal commentstring=//\ %s

	" markdown 允许自动换行
	au FileType markdown setlocal wrap

	" lisp 进行微调
	au FileType lisp setlocal ts=8 sts=2 sw=2 et

	" scala 微调
	au FileType scala setlocal sts=4 sw=4 noet

	" haskell 进行微调
	au FileType haskell setlocal et

	" quickfix 隐藏行号
	au FileType qf setlocal nonumber

	" 强制对某些扩展名的 filetype 进行纠正
	au BufNewFile,BufRead *.as setlocal filetype=actionscript
	au BufNewFile,BufRead *.pro setlocal filetype=prolog
	au BufNewFile,BufRead *.es setlocal filetype=erlang
	au BufNewFile,BufRead *.asc setlocal filetype=asciidoc
	au BufNewFile,BufRead *.vl setlocal filetype=verilog
    au BufNewFile,BufRead *.m setlocal  filetype=matlab
	" ros related
    au BufNewFile,BufRead *.launch setlocal  filetype=xml

augroup END


" ============================= TabSize =======================
" vim: set ts=4 sw=4 tw=78 noet :


"----------------------------------------------------------------------
" 默认缩进模式（可以后期覆盖）
"----------------------------------------------------------------------

" 设置缩进宽度
set sw=4

" 设置 TAB 宽度
set ts=4

" 禁止展开 tab (noexpandtab)
set noet

" 如果后面设置了 expandtab 那么展开 tab 为多少字符
set softtabstop=4


augroup PythonTab
	au!
	" 如果你需要 python 里用 tab，那么反注释下面这行字，否则vim会在打开py文件
	" 时自动设置成空格缩进。
	"au FileType python setlocal shiftwidth=4 tabstop=4 noexpandtab
augroup END

" ================================== STYLE ================================
" vim: set ts=4 sw=4 tw=78 noet :


"----------------------------------------------------------------------
" 显示设置
"----------------------------------------------------------------------

" 总是显示状态栏
set laststatus=2

" 总是显示行号
set number

" 总是显示侧边栏（用于显示 mark/gitdiff/诊断信息）
set signcolumn=yes

" 总是显示标签栏
set showtabline=2

" 设置显示制表符等隐藏字符
set list

" 右下角显示命令
set showcmd

" 插入模式在状态栏下面显示 -- INSERT --，
" 先注释掉，默认已经为真了，如果这里再设置一遍会影响 echodoc 插件
" set showmode

" 水平切割窗口时，默认在右边显示新窗口
set splitright


"----------------------------------------------------------------------
" 颜色主题：色彩文件位于 colors 目录中
"----------------------------------------------------------------------

" 设置黑色背景
set background=dark

" 允许 256 色
set t_Co=256

" 设置颜色主题，会在所有 runtimepaths 的 colors 目录寻找同名配置
"color night-owl
colorscheme desert
" colorscheme one
set background=light
"color 1989
"----------------------------------------------------------------------
" 状态栏设置
"----------------------------------------------------------------------
set statusline=                                 " 清空状态了
set statusline+=\ %F                            " 文件名
set statusline+=\ [%1*%M%*%n%R%H]               " buffer 编号和状态
set statusline+=%=                              " 向右对齐
set statusline+=\ %y                            " 文件类型

" 最右边显示文件编码和行号等信息，并且固定在一个 group 中，优先占位
set statusline+=\ %0(%{&fileformat}\ [%{(&fenc==\"\"?&enc:&fenc).(&bomb?\",BOM\":\"\")}]\ %v:%l/%L%)


"----------------------------------------------------------------------
" 更改样式
"----------------------------------------------------------------------

" 更清晰的错误标注：默认一片红色背景，语法高亮都被搞没了
" 只显示红色或者蓝色下划线或者波浪线
hi! clear SpellBad
hi! clear SpellCap
hi! clear SpellRare
hi! clear SpellLocal
if has('gui_running')
	hi! SpellBad gui=undercurl guisp=red
	hi! SpellCap gui=undercurl guisp=blue
	hi! SpellRare gui=undercurl guisp=magenta
	hi! SpellRare gui=undercurl guisp=cyan
else
	hi! SpellBad term=standout ctermfg=1 term=underline cterm=underline
	hi! SpellCap term=underline cterm=underline
	hi! SpellRare term=underline cterm=underline
	hi! SpellLocal term=underline cterm=underline
endif

" 去掉 sign column 的白色背景
hi! SignColumn guibg=NONE ctermbg=NONE

" 修改行号为浅灰色，默认主题的黄色行号很难看，换主题可以仿照修改
highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE 
	\ gui=NONE guifg=DarkGrey guibg=NONE

" 修正补全目录的色彩：默认太难看
hi! Pmenu guibg=gray guifg=black ctermbg=gray ctermfg=black
hi! PmenuSel guibg=gray guifg=brown ctermbg=brown ctermfg=gray


"----------------------------------------------------------------------
" 终端设置，隐藏行号和侧边栏
"----------------------------------------------------------------------
if has('terminal') && exists(':terminal') == 2
	if exists('##TerminalOpen')
		augroup VimUnixTerminalGroup
			au! 
			au TerminalOpen * setlocal nonumber signcolumn=no
		augroup END
	endif
endif


"----------------------------------------------------------------------
" quickfix 设置，隐藏行号
"----------------------------------------------------------------------
augroup VimInitStyle
	au!
	au FileType qf setlocal nonumber
augroup END


"----------------------------------------------------------------------
" 标签栏文字风格：默认为零，GUI 模式下空间大，按风格 3显示
" 0: filename.txt
" 2: 1 - filename.txt
" 3: [1] filename.txt
"----------------------------------------------------------------------
if has('gui_running')
	let g:config_vim_tab_style = 3
endif


"----------------------------------------------------------------------
" 终端下的 tabline
"----------------------------------------------------------------------
function! Vim_NeatTabLine()
	let s = ''
	for i in range(tabpagenr('$'))
		" select the highlighting
		if i + 1 == tabpagenr()
			let s .= '%#TabLineSel#'
		else
			let s .= '%#TabLine#'
		endif

		" set the tab page number (for mouse clicks)
		let s .= '%' . (i + 1) . 'T'

		" the label is made by MyTabLabel()
		let s .= ' %{Vim_NeatTabLabel(' . (i + 1) . ')} '
	endfor

	" after the last tab fill with TabLineFill and reset tab page nr
	let s .= '%#TabLineFill#%T'

	" right-align the label to close the current tab page
	if tabpagenr('$') > 1
		let s .= '%=%#TabLine#%999XX'
	endif

	return s
endfunc


"----------------------------------------------------------------------
" 需要显示到标签上的文件名
"----------------------------------------------------------------------
function! Vim_NeatBuffer(bufnr, fullname)
	let l:name = bufname(a:bufnr)
	if getbufvar(a:bufnr, '&modifiable')
		if l:name == ''
			return '[No Name]'
		else
			if a:fullname 
				return fnamemodify(l:name, ':p')
			else
				let aname = fnamemodify(l:name, ':p')
				let sname = fnamemodify(aname, ':t')
				if sname == ''
					let test = fnamemodify(aname, ':h:t')
					if test != ''
						return '<'. test . '>'
					endif
				endif
				return sname
			endif
		endif
	else
		let l:buftype = getbufvar(a:bufnr, '&buftype')
		if l:buftype == 'quickfix'
			return '[Quickfix]'
		elseif l:name != ''
			if a:fullname 
				return '-'.fnamemodify(l:name, ':p')
			else
				return '-'.fnamemodify(l:name, ':t')
			endif
		else
		endif
		return '[No Name]'
	endif
endfunc


"----------------------------------------------------------------------
" 标签栏文字，使用 [1] filename 的模式
"----------------------------------------------------------------------
function! Vim_NeatTabLabel(n)
	let l:buflist = tabpagebuflist(a:n)
	let l:winnr = tabpagewinnr(a:n)
	let l:bufnr = l:buflist[l:winnr - 1]
	let l:fname = Vim_NeatBuffer(l:bufnr, 0)
	let l:num = a:n
	let style = get(g:, 'config_vim_tab_style', 0)
	if style == 0
		return l:fname
	elseif style == 1
		return "[".l:num."] ".l:fname
	elseif style == 2
		return "".l:num." - ".l:fname
	endif
	if getbufvar(l:bufnr, '&modified')
		return "[".l:num."] ".l:fname." +"
	endif
	return "[".l:num."] ".l:fname
endfunc


"----------------------------------------------------------------------
" GUI 下的标签文字，使用 [1] filename 的模式
"----------------------------------------------------------------------
function! Vim_NeatGuiTabLabel()
	let l:num = v:lnum
	let l:buflist = tabpagebuflist(l:num)
	let l:winnr = tabpagewinnr(l:num)
	let l:bufnr = l:buflist[l:winnr - 1]
	let l:fname = Vim_NeatBuffer(l:bufnr, 0)
	let style = get(g:, 'config_vim_tab_style', 0)
	if style == 0
		return l:fname
	elseif style == 1
		return "[".l:num."] ".l:fname
	elseif style == 2
		return "".l:num." - ".l:fname
	endif
	if getbufvar(l:bufnr, '&modified')
		return "[".l:num."] ".l:fname." +"
	endif
	return "[".l:num."] ".l:fname
endfunc



"----------------------------------------------------------------------
" 设置 GUI 标签的 tips: 显示当前标签有哪些窗口
"----------------------------------------------------------------------
function! Vim_NeatGuiTabTip()
	let tip = ''
	let bufnrlist = tabpagebuflist(v:lnum)
	for bufnr in bufnrlist
		" separate buffer entries
		if tip != ''
			let tip .= " \n"
		endif
		" Add name of buffer
		let name = Vim_NeatBuffer(bufnr, 1)
		let tip .= name
		" add modified/modifiable flags
		if getbufvar(bufnr, "&modified")
			let tip .= ' [+]'
		endif
		if getbufvar(bufnr, "&modifiable")==0
			let tip .= ' [-]'
		endif
	endfor
	return tip
endfunc


"----------------------------------------------------------------------
" 标签栏最终设置
"----------------------------------------------------------------------
set tabline=%!Vim_NeatTabLine()
set guitablabel=%{Vim_NeatGuiTabLabel()}
set guitabtooltip=%{Vim_NeatGuiTabTip()}


"----------------------------------------------------------------------
" 标签栏最终设置
"----------------------------------------------------------------------


"============================ Keymaps =================================

" vim: set ts=4 sw=4 tw=78 noet :

"----------------------------------------------------------------------
" INSERT 模式下 map jk to ESC
"----------------------------------------------------------------------
inoremap jk <Esc>


"----------------------------------------------------------------------
" Change Leader to space
"----------------------------------------------------------------------
"nnoremap <SPACE> <Nop>
"let mapleader = "\<Space>"
let mapleader = ","
"let g:mapleader = "\<SPACE>"
"nnoremap <Leader>a :echo "Hey there space"<CR>


"----------------------------------------------------------------------
" Add doom like save
"----------------------------------------------------------------------
noremap <silent><space>fs :update<CR>
noremap <silent><space>fS :saveas 
"----------------------------------------------------------------------
" 开关行号显示的方式 <slient><leader><C-l>
"----------------------------------------------------------------------
" setglobal relativenumber
autocmd WinEnter * :setlocal relativenumber
autocmd WinLeave,FocusLost * :setlocal number
autocmd InsertEnter * :setlocal number
autocmd InsertLeave * :setlocal relativenumber

function! g:ToggleNuMode()
  if(&relativenumber == 1)
    set number
  else
    set relativenumber
  endif
endfunc

map <silent><space>tl :call g:ToggleNuMode()<CR>


"----------------------------------------------------------------------
" INSERT 模式下使用 EMACS 键位
"----------------------------------------------------------------------
inoremap <c-a> <home>
inoremap <c-e> <end>
inoremap <c-d> <del>
inoremap <c-_> <c-k>


"----------------------------------------------------------------------
" 设置 CTRL+HJKL 移动光标（INSERT 模式偶尔需要移动的方便些）
" 使用 SecureCRT/XShell 等终端软件需设置：Backspace sends delete
" 详见：http://www.skywind.me/blog/archives/2021
"----------------------------------------------------------------------
noremap <C-h> <left>
noremap <C-j> <down>
noremap <C-k> <up>
noremap <C-l> <right>
inoremap <C-h> <left>
inoremap <C-j> <down>
inoremap <C-k> <up>
inoremap <C-l> <right>


"----------------------------------------------------------------------
" 命令模式的快速移动
"----------------------------------------------------------------------
cnoremap <c-h> <left>
cnoremap <c-j> <down>
cnoremap <c-k> <up>
cnoremap <c-l> <right>
cnoremap <c-a> <home>
cnoremap <c-e> <end>
cnoremap <c-f> <c-d>
cnoremap <c-b> <left>
cnoremap <c-d> <del>
cnoremap <c-_> <c-k>


"----------------------------------------------------------------------
" <leader>+数字键 切换tab
"----------------------------------------------------------------------
noremap <silent><leader>1 1gt<cr>
noremap <silent><leader>2 2gt<cr>
noremap <silent><leader>3 3gt<cr>
noremap <silent><leader>4 4gt<cr>
noremap <silent><leader>5 5gt<cr>
noremap <silent><leader>6 6gt<cr>
noremap <silent><leader>7 7gt<cr>
noremap <silent><leader>8 8gt<cr>
noremap <silent><leader>9 9gt<cr>
noremap <silent><leader>0 10gt<cr>


"----------------------------------------------------------------------
" ALT+N 切换 tab
"----------------------------------------------------------------------
noremap <silent><m-1> :tabn 1<cr>
noremap <silent><m-2> :tabn 2<cr>
noremap <silent><m-3> :tabn 3<cr>
noremap <silent><m-4> :tabn 4<cr>
noremap <silent><m-5> :tabn 5<cr>
noremap <silent><m-6> :tabn 6<cr>
noremap <silent><m-7> :tabn 7<cr>
noremap <silent><m-8> :tabn 8<cr>
noremap <silent><m-9> :tabn 9<cr>
noremap <silent><m-0> :tabn 10<cr>
inoremap <silent><m-1> <ESC>:tabn 1<cr>
inoremap <silent><m-2> <ESC>:tabn 2<cr>
inoremap <silent><m-3> <ESC>:tabn 3<cr>
inoremap <silent><m-4> <ESC>:tabn 4<cr>
inoremap <silent><m-5> <ESC>:tabn 5<cr>
inoremap <silent><m-6> <ESC>:tabn 6<cr>
inoremap <silent><m-7> <ESC>:tabn 7<cr>
inoremap <silent><m-8> <ESC>:tabn 8<cr>
inoremap <silent><m-9> <ESC>:tabn 9<cr>
inoremap <silent><m-0> <ESC>:tabn 10<cr>


" MacVim 允许 CMD+数字键快速切换标签
if has("gui_macvim")
	set macmeta
	noremap <silent><d-1> :tabn 1<cr>
	noremap <silent><d-2> :tabn 2<cr>
	noremap <silent><d-3> :tabn 3<cr>
	noremap <silent><d-4> :tabn 4<cr>
	noremap <silent><d-5> :tabn 5<cr>
	noremap <silent><d-6> :tabn 6<cr>
	noremap <silent><d-7> :tabn 7<cr>
	noremap <silent><d-8> :tabn 8<cr>
	noremap <silent><d-9> :tabn 9<cr>
	noremap <silent><d-0> :tabn 10<cr>
	inoremap <silent><d-1> <ESC>:tabn 1<cr>
	inoremap <silent><d-2> <ESC>:tabn 2<cr>
	inoremap <silent><d-3> <ESC>:tabn 3<cr>
	inoremap <silent><d-4> <ESC>:tabn 4<cr>
	inoremap <silent><d-5> <ESC>:tabn 5<cr>
	inoremap <silent><d-6> <ESC>:tabn 6<cr>
	inoremap <silent><d-7> <ESC>:tabn 7<cr>
	inoremap <silent><d-8> <ESC>:tabn 8<cr>
	inoremap <silent><d-9> <ESC>:tabn 9<cr>
	inoremap <silent><d-0> <ESC>:tabn 10<cr>
endif



"----------------------------------------------------------------------
" 缓存：插件 unimpaired 中定义了 [b, ]b 来切换缓存
"----------------------------------------------------------------------
noremap <silent> <leader>bn :bn<cr>
noremap <silent> <leader>bp :bp<cr>


"----------------------------------------------------------------------
" TAB：创建，关闭，上一个，下一个，左移，右移
" 其实还可以用原生的 CTRL+PageUp, CTRL+PageDown 来切换标签
"----------------------------------------------------------------------

noremap <silent> <leader>tc :tabnew<cr>
noremap <silent> <leader>tq :tabclose<cr>
noremap <silent> <leader>tn :tabnext<cr>
noremap <silent> <leader>tp :tabprev<cr>
noremap <silent> <leader>to :tabonly<cr>
noremap <silent> <space><tab>n :tabnew<cr>
noremap <silent> <space><tab>[ :tabprev<cr>
noremap <silent> <space><tab>] :tabnext<cr>
noremap <silent> <space><tab><tab> :tabnext<cr>
noremap <silent> <space><tab>. :tabprev<cr>
noremap <silent> <space><tab>x :tabclose<cr>
noremap <silent> <space><tab>q :tabclose<cr>
noremap <silent> <space><tab>o :tabonly<cr>

" 左移 tab
function! Tab_MoveLeft()
	let l:tabnr = tabpagenr() - 2
	if l:tabnr >= 0
		exec 'tabmove '.l:tabnr
	endif
endfunc

" 右移 tab
function! Tab_MoveRight()
	let l:tabnr = tabpagenr() + 1
	if l:tabnr <= tabpagenr('$')
		exec 'tabmove '.l:tabnr
	endif
endfunc

noremap <silent><leader>tl :call Tab_MoveLeft()<cr>
noremap <silent><leader>tr :call Tab_MoveRight()<cr>
noremap <silent><m-left> :call Tab_MoveLeft()<cr>
noremap <silent><m-right> :call Tab_MoveRight()<cr>


"----------------------------------------------------------------------
" ALT + CTRL 键移动增强
"----------------------------------------------------------------------

noremap <c-j> jjj
noremap <c-k> kkk

" ALT+h/l 快速左右按单词移动（正常模式+插入模式）
noremap <m-h> b
noremap <m-l> w
inoremap <m-h> <c-left>
inoremap <m-l> <c-right>

" ALT+j/k 逻辑跳转下一行/上一行（按 wrap 逻辑换行进行跳转） 
noremap <m-j> gj
noremap <m-k> gk
inoremap <m-j> <c-\><c-o>gj
inoremap <m-k> <c-\><c-o>gk

" 命令模式下的相同快捷
cnoremap <m-h> <c-left>
cnoremap <m-l> <c-right>

" ALT+y 删除到行末
noremap <m-y> d$
inoremap <m-y> <c-\><c-o>d$


"----------------------------------------------------------------------
" 窗口切换：ALT+SHIFT+hjkl
" 传统的 CTRL+hjkl 移动窗口不适用于 vim 8.1 的终端模式，CTRL+hjkl 在
" bash/zsh 及带文本界面的程序中都是重要键位需要保留，不能 tnoremap 的
"----------------------------------------------------------------------
noremap <m-H> <c-w>h
noremap <m-L> <c-w>l
noremap <m-J> <c-w>j
noremap <m-K> <c-w>k
inoremap <m-H> <esc><c-w>h
inoremap <m-L> <esc><c-w>l
inoremap <m-J> <esc><c-w>j
inoremap <m-K> <esc><c-w>k

if has('terminal') && exists(':terminal') == 2 && has('patch-8.1.1')
	" vim 8.1 支持 termwinkey ，不需要把 terminal 切换成 normal 模式
	" 设置 termwinkey 为 CTRL 加减号（GVIM），有些终端下是 CTRL+?
	" 后面四个键位是搭配 termwinkey 的，如果 termwinkey 更改，也要改
	set termwinkey=<c-_>
	tnoremap <m-H> <c-_>h
	tnoremap <m-L> <c-_>l
	tnoremap <m-J> <c-_>j
	tnoremap <m-K> <c-_>k
	tnoremap <m-q> <c-\><c-n>
elseif has('nvim')
	" neovim 没有 termwinkey 支持，必须把 terminal 切换回 normal 模式
	tnoremap <m-H> <c-\><c-n><c-w>h
	tnoremap <m-L> <c-\><c-n><c-w>l
	tnoremap <m-J> <c-\><c-n><c-w>j
	tnoremap <m-K> <c-\><c-n><c-w>k
	tnoremap <m-q> <c-\><c-n>
endif



"----------------------------------------------------------------------
" 编译运行 C/C++ 项目
" 详细见：http://www.skywind.me/blog/archives/2084
"----------------------------------------------------------------------

" 自动打开 quickfix window ，高度为 6
let g:asyncrun_open = 6

" 任务结束时候响铃提醒
let g:asyncrun_bell = 1

" 设置 F10 打开/关闭 Quickfix 窗口
"nnoremap <F10> :call asyncrun#quickfix_toggle(6)<cr>

" F9 编译 C/C++ 文件
"nnoremap <silent> <F9> :AsyncRun gcc -Wall -O2 "$(VIM_FILEPATH)" -o "$(VIM_FILEDIR)/$(VIM_FILENOEXT)" <cr>

" F5 运行文件
"nnoremap <silent> <F5> :call ExecuteFile()<cr>

" F7 编译项目
"nnoremap <silent> <F7> :AsyncRun -cwd=<root> make <cr>

" F8 运行项目
"nnoremap <silent> <F8> :AsyncRun -cwd=<root> -raw make run <cr>

" F6 测试项目
"nnoremap <silent> <F6> :AsyncRun -cwd=<root> -raw make test <cr>

" 更新 cmake
"nnoremap <silent> <F4> :AsyncRun -cwd=<root> cmake . <cr>

" Windows 下支持直接打开新 cmd 窗口运行
"if has('win32') || has('win64')
""	nnoremap <silent> <F8> :AsyncRun -cwd=<root> -mode=4 make run <cr>
"endif


"----------------------------------------------------------------------
" F5 运行当前文件：根据文件类型判断方法，并且输出到 quickfix 窗口
"----------------------------------------------------------------------
"function! ExecuteFile()
""	let cmd = ''
""	if index(['c', 'cpp', 'rs', 'go'], &ft) >= 0
""		" native 语言，把当前文件名去掉扩展名后作为可执行运行
""		" 写全路径名是因为后面 -cwd=? 会改变运行时的当前路径，所以写全路径
""		" 加双引号是为了避免路径中包含空格
""		let cmd = '"$(VIM_FILEDIR)/$(VIM_FILENOEXT)"'
""	elseif &ft == 'python'
""		let $PYTHONUNBUFFERED=1 " 关闭 python 缓存，实时看到输出
""		let cmd = 'python "$(VIM_FILEPATH)"'
""	elseif &ft == 'javascript'
""		let cmd = 'node "$(VIM_FILEPATH)"'
""	elseif &ft == 'perl'
""		let cmd = 'perl "$(VIM_FILEPATH)"'
""	elseif &ft == 'ruby'
""		let cmd = 'ruby "$(VIM_FILEPATH)"'
""	elseif &ft == 'php'
""		let cmd = 'php "$(VIM_FILEPATH)"'
""	elseif &ft == 'lua'
""		let cmd = 'lua "$(VIM_FILEPATH)"'
""	elseif &ft == 'zsh'
""		let cmd = 'zsh "$(VIM_FILEPATH)"'
""	elseif &ft == 'ps1'
""		let cmd = 'powershell -file "$(VIM_FILEPATH)"'
""	elseif &ft == 'vbs'
""		let cmd = 'cscript -nologo "$(VIM_FILEPATH)"'
""	elseif &ft == 'sh'
""		let cmd = 'bash "$(VIM_FILEPATH)"'
""	else
""		return
""	endif
""	" Windows 下打开新的窗口 (-mode=4) 运行程序，其他系统在 quickfix 运行
""	" -raw: 输出内容直接显示到 quickfix window 不匹配 errorformat
""	" -save=2: 保存所有改动过的文件
""	" -cwd=$(VIM_FILEDIR): 运行初始化目录为文件所在目录
""	if has('win32') || has('win64')
""		exec 'AsyncRun -cwd=$(VIM_FILEDIR) -raw -save=2 -mode=4 '. cmd
""	else
""		exec 'AsyncRun -cwd=$(VIM_FILEDIR) -raw -save=2 -mode=0 '. cmd
""	endif
""endfunc



"----------------------------------------------------------------------
" space-f-* 在项目目录下 Grep 光标下单词，默认 C/C++/Py/Js ，扩展名自己扩充
" 支持 rg/grep/findstr ，其他类型可以自己扩充
" 不是在当前目录 grep，而是会去到当前文件所属的项目目录 project root
" 下面进行 grep，这样能方便的对相关项目进行搜索
"----------------------------------------------------------------------
if executable('rg')
	noremap <silent><space>f* :AsyncRun! -cwd=<root> rg -n --no-heading 
				\ --color never -g *.h -g *.c* -g *.py -g *.js -g *.vim 
				\ <C-R><C-W> "<root>" <cr>
elseif has('win32') || has('win64')
	noremap <silent><space>f* :AsyncRun! -cwd=<root> findstr /n /s /C:"<C-R><C-W>" 
				\ "\%CD\%\*.h" "\%CD\%\*.c*" "\%CD\%\*.py" "\%CD\%\*.js"
				\ "\%CD\%\*.vim"
				\ <cr>
else
	noremap <silent><space>f* :AsyncRun! -cwd=<root> grep -n -s -R <C-R><C-W> 
				\ --include='*.h' --include='*.c*' --include='*.py' 
				\ --include='*.js' --include='*.vim'
				\ '<root>' <cr>
endif



"----------------------------------------------------------------------
" Change the background
"----------------------------------------------------------------------
noremap <silent><space>t<c-l> :set background=light <cr>
noremap <silent><space>t<c-d> :set background=dark <cr>


"----------------------------------------------------------------------
" Doom 一样的窗口切换方法
"----------------------------------------------------------------------
noremap <silent><space>ws :<c-U>split<cr>
noremap <silent><space>wv :<c-U>vsplit<cr>
noremap <silent><space>wq <c-w>q
noremap <space>wh <c-w>h
noremap <space>wl <c-w>l
noremap <space>wj <c-w>j
noremap <space>wq <c-w>k
noremap <space>w= <c-w>=
noremap <space>w+ <c-w>+
noremap <space>w- <c-w>-
noremap <space>w< <c-w><
noremap <space>w> <c-w>>
noremap <space>wo <c-w>o