" vim: set ts=4 sw=4 tw=78 noet :



"----------------------------------------------------------------------
" 默认情况下的分组，可以再前面覆盖之
"----------------------------------------------------------------------
if !exists('g:bundle_group')
	let g:bundle_group = ['basic', 'tags', 'enhanced', 'filetypes', 'textobj']
	let g:bundle_group += ['tags', 'airline', 'nerdtree', 'ale', 'echodoc']
	let g:bundle_group += ['leaderf']
	let g:bundle_group += ['coc']
endif


"----------------------------------------------------------------------
" 计算当前 vim-init 的子路径
"----------------------------------------------------------------------
let s:home = fnamemodify(resolve(expand('<sfile>:p')), ':h:h')

function! s:path(path)
	let path = expand(s:home . '/' . a:path )
	return substitute(path, '\\', '/', 'g')
endfunc


"----------------------------------------------------------------------
" 在 ~/.vim/nvim_bundles 下安装插件
"----------------------------------------------------------------------
call plug#begin(get(g:, 'bundle_home', '~/.vim/nvim_bundles'))


"----------------------------------------------------------------------
" 默认插件 
"----------------------------------------------------------------------
" 使用 deoplete 来作为默认的不全插件
" if has('nvim')
"   Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" else
"   Plug 'Shougo/deoplete.nvim'
"   Plug 'roxma/nvim-yarp'
"   Plug 'roxma/vim-hug-neovim-rpc'
" endif
" set runtimepath+=~/.vim/bundles/deoplete.nvim/
" let g:deoplete#enable_at_startup = 1
" Plug 'ycm-core/YouCompleteMe'

" 全文快速移动，<leader><leader>f{char} 即可触发
Plug 'easymotion/vim-easymotion'

" <Leader>f{char} to move to {char}
map  <space>jf <Plug>(easymotion-bd-f)
nmap <space>jf <Plug>(easymotion-overwin-f)

" s{char}{char} to move to {char}{char}
nmap s <Plug>(easymotion-overwin-f2)

" Move to line
map <space>jL <Plug>(easymotion-bd-jk)
nmap <space>jL <Plug>(easymotion-overwin-line)

" Move to word
map  <space>jw <Plug>(easymotion-bd-w)
nmap <space>jw <Plug>(easymotion-overwin-w)

" 文件浏览器，代替 netrw
Plug 'justinmk/vim-dirvish'

" 表格对齐，使用命令 Tabularize
Plug 'godlygeek/tabular', { 'on': 'Tabularize' }

" Diff 增强，支持 histogram / patience 等更科学的 diff 算法
Plug 'chrisbra/vim-diff-enhanced'


"----------------------------------------------------------------------
" Dirvish 设置：自动排序并隐藏文件，同时定位到相关文件
" 这个排序函数可以将目录排在前面，文件排在后面，并且按照字母顺序排序
" 比默认的纯按照字母排序更友好点。
"----------------------------------------------------------------------
function! s:setup_dirvish()
	if &buftype != 'nofile' && &filetype != 'dirvish'
		return
	endif
	if has('nvim')
		return
	endif
	" 取得光标所在行的文本（当前选中的文件名）
	let text = getline('.')
	if ! get(g:, 'dirvish_hide_visible', 0)
		exec 'silent keeppatterns g@\v[\/]\.[^\/]+[\/]?$@d _'
	endif
	" 排序文件名
	exec 'sort ,^.*[\/],'
	let name = '^' . escape(text, '.*[]~\') . '[/*|@=|\\*]\=\%($\|\s\+\)'
	" 定位到之前光标处的文件
	call search(name, 'wc')
	noremap <silent><buffer> ~ :Dirvish ~<cr>
	noremap <buffer> % :e %
endfunc

augroup MyPluginSetup
	autocmd!
	autocmd FileType dirvish call s:setup_dirvish()
augroup END


"----------------------------------------------------------------------
" 基础插件
"----------------------------------------------------------------------
if index(g:bundle_group, 'basic') >= 0

	" 展示开始画面，显示最近编辑过的文件
	Plug 'mhinz/vim-startify'

	" 一次性安装一大堆 colorscheme
	Plug 'flazz/vim-colorschemes'
	Plug 'haishanh/night-owl.vim'
	Plug 'rakr/vim-one'

	let g:airline_theme='one'
	
	if(has("termguicolors"))
		set termguicolors 
	endif
	" 支持库，给其他插件用的函数库
	Plug 'xolox/vim-misc'

	" 用于在侧边符号栏显示 marks （ma-mz 记录的位置）
	Plug 'kshenoy/vim-signature'

	" 用于在侧边符号栏显示 git/svn 的 diff
	Plug 'mhinz/vim-signify'

	" 根据 quickfix 中匹配到的错误信息，高亮对应文件的错误行
	" 使用 :RemoveErrorMarkers 命令或者 <space>ha 清除错误
	Plug 'mh21/errormarker.vim'

	" 使用 ALT+e 会在不同窗口/标签上显示 A/B/C 等编号，然后字母直接跳转
	Plug 't9md/vim-choosewin'

	" 提供基于 TAGS 的定义预览，函数参数预览，quickfix 预览
	Plug 'skywind3000/vim-preview'

	" Git 支持
	Plug 'tpope/vim-fugitive'
	Plug 'lambdalisue/gina.vim'

	" 使用 ALT+E 来选择窗口
	nmap <m-e> <Plug>(choosewin)

	" 默认不显示 startify
	let g:startify_disable_at_vimenter = 1
	let g:startify_session_dir = '~/.vim/session'

	" 使用 <space>ha 清除 errormarker 标注的错误
	noremap <silent><space>ha :RemoveErrorMarkers<cr>

	" signify 调优
	let g:signify_vcs_list = ['git', 'svn']
	let g:signify_sign_add               = '+'
	let g:signify_sign_delete            = '_'
	let g:signify_sign_delete_first_line = '‾'
	let g:signify_sign_change            = '~'
	let g:signify_sign_changedelete      = g:signify_sign_change

	" git 仓库使用 histogram 算法进行 diff
	let g:signify_vcs_cmds = {
			\ 'git': 'git diff --no-color --diff-algorithm=histogram --no-ext-diff -U0 -- %f',
			\}
endif


"----------------------------------------------------------------------
" 增强插件
"----------------------------------------------------------------------
if index(g:bundle_group, 'enhanced') >= 0

	" 用 v 选中一个区域后，ALT_+/- 按分隔符扩大/缩小选区
	Plug 'terryma/vim-expand-region'

	" 快速文件搜索
	Plug 'junegunn/fzf'

	" 给不同语言提供字典补全，插入模式下 c-x c-k 触发
	Plug 'asins/vim-dict'

	" 使用 :FlyGrep 命令进行实时 grep
	Plug 'wsdjeg/FlyGrep.vim'

	" 使用 :CtrlSF 命令进行模仿 sublime 的 grep
	Plug 'dyng/ctrlsf.vim'

	" 配对括号和引号自动补全
	Plug 'Raimondi/delimitMate'

	" 提供 gist 接口
	Plug 'lambdalisue/vim-gista', { 'on': 'Gista' }
	
	" ALT_+/- 用于按分隔符扩大缩小 v 选区
	map <m-=> <Plug>(expand_region_expand)
	map <m--> <Plug>(expand_region_shrink)

	" 注释插件
	" Use gcc to comment out a line (takes a count)
	" gc to comment out the target of a motion
	" gc in visual mode to comment out the selection, 
	"   and gc in operator pending mode to target a comment
	" as part of a :global invocation like with :g/TODO/Commentary
	Plug 'tpope/vim-commentary'
	" 手动添加注释方式
	autocmd FileType apache setlocal commentstring=#\ %s
	noremap <space>c/ :Commentary<cr>

	" 多行编辑
	Plug 'terryma/vim-multiple-cursors'
	" 可以用 <C-N> 来启动一个选择
	" next: c-n
	" skip: c-x 
	" prev: c-p
	" select-all: A-n
	" let g:multi_cursor_use_default_mapping=0
	" " Default mapping
	" let g:multi_cursor_start_word_key      = '<C-n>'
	" let g:multi_cursor_select_all_word_key = '<A-n>'
	" let g:multi_cursor_start_key           = 'g<C-n>'
	" let g:multi_cursor_select_all_key      = 'g<A-n>'
	" let g:multi_cursor_next_key            = '<C-n>'
	" let g:multi_cursor_prev_key            = '<C-p>'
	" let g:multi_cursor_skip_key            = '<C-x>'
	" let g:multi_cursor_quit_key            = '<Esc>'

	" bookmarket
	Plug 'MattesGroeger/vim-bookmarks'
	let g:bookmark_no_default_key_mappings = 1
	nmap <space>mm <Plug>BookmarkToggle
	nmap <space>mi <Plug>BookmarkAnnotate
	nmap <space>ma <Plug>BookmarkShowAll
	nmap <space>mj <Plug>BookmarkNext
	nmap <space>mk <Plug>BookmarkPrev
	nmap <space>mc <Plug>BookmarkClear
	nmap <space>mx <Plug>BookmarkClearAll
	nmap <space>mkk <Plug>BookmarkMoveUp
	nmap <space>mjj <Plug>BookmarkMoveDown
	nmap <space>mg <Plug>BookmarkMoveToLine

	"TODOList
	Plug 'nvim-lua/plenary.nvim'
	Plug 'folke/todo-comments.nvim'

	" <space>a  app
	" <space>at todo app
	nnoremap <silent><nowait> <space>atq  :<C-u>TodoQuickFix<cr>
	nnoremap <silent><nowait> <space>atl  :<C-u>TodoList<cr>
	nnoremap <silent><nowait> <space>att  :<C-u>TodoTrouble<cr>
	nnoremap <silent><nowait> <space>ats  :<C-u>TodoTelescope<cr>

	"添加文件图标
	Plug 'ryanoasis/vim-devicons'

	"AsyncRun
	Plug 'skywind3000/asyncrun.vim'
endif


"----------------------------------------------------------------------
" 自动生成 ctags/gtags，并提供自动索引功能
" 不在 git/svn 内的项目，需要在项目根目录 touch 一个空的 .root 文件
" 详细用法见：https://zhuanlan.zhihu.com/p/36279445
"----------------------------------------------------------------------
" if index(g:bundle_group, 'tags') >= 0

" 	" 提供 ctags/gtags 后台数据库自动更新功能
" 	Plug 'ludovicchabant/vim-gutentags'

" 	" 提供 GscopeFind 命令并自动处理好 gtags 数据库切换
" 	" 支持光标移动到符号名上：<leader>cg 查看定义，<leader>cs 查看引用
" 	Plug 'skywind3000/gutentags_plus'

" 	" 设定项目目录标志：除了 .git/.svn 外，还有 .root 文件
" 	let g:gutentags_project_root = ['.root']
" 	let g:gutentags_ctags_tagfile = '.tags'

" 	" 默认生成的数据文件集中到 ~/.cache/tags 避免污染项目目录，好清理
" 	let g:gutentags_cache_dir = expand('~/.cache/tags')

" 	" 默认禁用自动生成
" 	let g:gutentags_modules = [] 

" 	" 如果有 ctags 可执行就允许动态生成 ctags 文件
" 	if executable('ctags')
" 		let g:gutentags_modules += ['ctags']
" 	endif

" 	" 如果有 gtags 可执行就允许动态生成 gtags 数据库
" 	if executable('gtags') && executable('gtags-cscope')
" 		let g:gutentags_modules += ['gtags_cscope']
" 	endif

" 	" 设置 ctags 的参数
" 	let g:gutentags_ctags_extra_args = []
" 	let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
" 	let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
" 	let g:gutentags_ctags_extra_args += ['--c-kinds=+px']

" 	" 使用 universal-ctags 的话需要下面这行，请反注释
" 	" let g:gutentags_ctags_extra_args += ['--output-format=e-ctags']

" 	" 禁止 gutentags 自动链接 gtags 数据库
" 	let g:gutentags_auto_add_gtags_cscope = 0
" endif


"----------------------------------------------------------------------
" 文本对象：textobj 全家桶
"----------------------------------------------------------------------
if index(g:bundle_group, 'textobj') >= 0

	" 基础插件：提供让用户方便的自定义文本对象的接口
	Plug 'kana/vim-textobj-user'

	" indent 文本对象：ii/ai 表示当前缩进，vii 选中当缩进，cii 改写缩进
	Plug 'kana/vim-textobj-indent'

	" 语法文本对象：iy/ay 基于语法的文本对象
	Plug 'kana/vim-textobj-syntax'

	" 函数文本对象：if/af 支持 c/c++/vim/java
	Plug 'kana/vim-textobj-function', { 'for':['c', 'cpp', 'vim', 'java'] }

	" 参数文本对象：i,/a, 包括参数或者列表元素
	Plug 'sgur/vim-textobj-parameter'

	" 提供 python 相关文本对象，if/af 表示函数，ic/ac 表示类
	Plug 'bps/vim-textobj-python', {'for': 'python'}

	" 提供 uri/url 的文本对象，iu/au 表示
	Plug 'jceb/vim-textobj-uri'
endif


"----------------------------------------------------------------------
" 文件类型扩展
"----------------------------------------------------------------------
if index(g:bundle_group, 'filetypes') >= 0

	" powershell 脚本文件的语法高亮
	Plug 'pprovost/vim-ps1', { 'for': 'ps1' }

	" lua 语法高亮增强
	Plug 'tbastos/vim-lua', { 'for': 'lua' }

	" C++ 语法高亮增强，支持 11/14/17 标准
	Plug 'octol/vim-cpp-enhanced-highlight', { 'for': ['c', 'cpp'] }

	" 额外语法文件
	Plug 'justinmk/vim-syntax-extra', { 'for': ['c', 'bison', 'flex', 'cpp'] }

	" python 语法文件增强
	Plug 'vim-python/python-syntax', { 'for': ['python'] }

	" rust 语法增强
	Plug 'rust-lang/rust.vim', { 'for': 'rust' }

	" Typescript support
	Plug 'leafgarland/typescript-vim'
	 
	" vim org-mode 
	Plug 'jceb/vim-orgmode', { 'for': 'org' }

	"----------------------------------------------------------------
	"-----Nim support----------------------------------------
	"----------------------------------------------------------------

	Plug 'zah/nim.vim'

	" fun! JumpToDef()
	" 	if exists("*GotoDefinition_" . &filetype)
	" 		call GotoDefinition_{&filetype}()
	" 	else
	" 		exe "norm! \<C-]>"
	" 	endif
	" endf

	" " Jump to tag
	" nn <M-g> :call JumpToDef()<cr>
	" ino <M-g> <esc>:call JumpToDef()<cr>i
endif


"----------------------------------------------------------------------
" airline
"----------------------------------------------------------------------
if index(g:bundle_group, 'airline') >= 0
	Plug 'vim-airline/vim-airline'
	Plug 'vim-airline/vim-airline-themes'
	let g:airline_left_sep = ''
	let g:airline_left_alt_sep = ''
	let g:airline_right_sep = ''
	let g:airline_right_alt_sep = ''
	let g:airline_powerline_fonts = 0
	let g:airline_exclude_preview = 1
	let g:airline_section_b = '%n'
	let g:airline_theme='one'
	let g:airline#extensions#branch#enabled = 0
	let g:airline#extensions#syntastic#enabled = 0
	let g:airline#extensions#fugitiveline#enabled = 0
	let g:airline#extensions#csv#enabled = 0
	let g:airline#extensions#vimagit#enabled = 0
endif


"----------------------------------------------------------------------
" NERDTree
"----------------------------------------------------------------------
if index(g:bundle_group, 'nerdtree') >= 0
	Plug 'scrooloose/nerdtree', {'on': ['NERDTree', 'NERDTreeFocus', 'NERDTreeToggle', 'NERDTreeCWD', 'NERDTreeFind'] }
	Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
	let g:NERDTreeMinimalUI = 0
	let g:NERDTreeDirArrows = 1
	let g:NERDTreeHijackNetrw = 0
	noremap <space>nn :NERDTree<cr>
	noremap <space>no :NERDTreeFocus<cr>
	noremap <space>nm :NERDTreeMirror<cr>
	noremap <space>nt :NERDTreeToggle<cr>
endif


"----------------------------------------------------------------------
" LanguageTool 语法检查
"----------------------------------------------------------------------
if index(g:bundle_group, 'grammer') >= 0
	Plug 'rhysd/vim-grammarous'
	noremap <space>rg :GrammarousCheck --lang=en-US --no-move-to-first-error --no-preview<cr>
	map <space>rr <Plug>(grammarous-open-info-window)
	map <space>rv <Plug>(grammarous-move-to-info-window)
	map <space>rs <Plug>(grammarous-reset)
	map <space>rx <Plug>(grammarous-close-info-window)
	map <space>rm <Plug>(grammarous-remove-error)
	map <space>rd <Plug>(grammarous-disable-rule)
	map <space>rn <Plug>(grammarous-move-to-next-error)
	map <space>rp <Plug>(grammarous-move-to-previous-error)
endif


"----------------------------------------------------------------------
" ale：动态语法检查
"----------------------------------------------------------------------
"if index(g:bundle_group, 'ale') >= 0
"	Plug 'w0rp/ale'
"
"	" 设定延迟和提示信息
"	let g:ale_completion_delay = 500
"	let g:ale_echo_delay = 20
"	let g:ale_lint_delay = 500
"	let g:ale_echo_msg_format = '[%linter%] %code: %%s'
"
"	" 设定检测的时机：normal 模式文字改变，或者离开 insert模式
"	" 禁用默认 INSERT 模式下改变文字也触发的设置，太频繁外，还会让补全窗闪烁
"	let g:ale_lint_on_text_changed = 'normal'
"	let g:ale_lint_on_insert_leave = 1
"
"	" 在 linux/mac 下降低语法检查程序的进程优先级（不要卡到前台进程）
"	if has('win32') == 0 && has('win64') == 0 && has('win32unix') == 0
"		let g:ale_command_wrapper = 'nice -n5'
"	endif
"
"	" 允许 airline 集成
"	let g:airline#extensions#ale#enabled = 1
"
"	" 编辑不同文件类型需要的语法检查器
"	let g:ale_linters = {
"				\ 'c': ['gcc', 'cppcheck'], 
"				\ 'cpp': ['gcc', 'cppcheck'], 
"				\ 'python': ['flake8', 'pylint'], 
"				\ 'lua': ['luac'], 
"				\ 'go': ['go build', 'gofmt'],
"				\ 'java': ['javac'],
"				\ 'javascript': ['eslint'], 
"				\ }
"
"
"	" 获取 pylint, flake8 的配置文件，在 vim-init/tools/conf 下面
"	function s:lintcfg(name)
"		let conf = s:path('tools/conf/')
"		let path1 = conf . a:name
"		let path2 = expand('~/.vim/linter/'. a:name)
"		if filereadable(path2)
"			return path2
"		endif
"		return shellescape(filereadable(path2)? path2 : path1)
"	endfunc
"
"	" 设置 flake8/pylint 的参数
"	let g:ale_python_flake8_options = '--conf='.s:lintcfg('flake8.conf')
"	let g:ale_python_pylint_options = '--rcfile='.s:lintcfg('pylint.conf')
"	let g:ale_python_pylint_options .= ' --disable=W'
"	let g:ale_c_gcc_options = '-Wall -O2 -std=c99'
"	let g:ale_cpp_gcc_options = '-Wall -O2 -std=c++14'
"	let g:ale_c_cppcheck_options = ''
"	let g:ale_cpp_cppcheck_options = ''
"
"	let g:ale_linters.text = ['textlint', 'write-good', 'languagetool']
"
"	" 如果没有 gcc 只有 clang 时（FreeBSD）
"	if executable('gcc') == 0 && executable('clang')
"		let g:ale_linters.c += ['clang']
"		let g:ale_linters.cpp += ['clang']
"	endif
"endif

"----------------------------------------------------------------------
" tabNine: tabNine 客户端
"----------------------------------------------------------------------
" if has('win32') || has('win64')
"   Plug 'tbodt/deoplete-tabnine', { 'do': 'powershell.exe .\install.ps1' }
" else
"   Plug 'tbodt/deoplete-tabnine', { 'do': './install.sh' }
" endif
" call deoplete#custom#source('deoplete-tabnine', 'rank', 999)
"----------------------------------------------------------------------
" ale: Vim LSP 客户端
"----------------------------------------------------------------------
"Plug 'dense-analysis/ale', {'as': 'ale-lsp'}
"
"call deoplete#custom#option('sources', {
"\ '_': ['ale', "deoplete-tabnine", "deoplete-vim-lsp"],
"\})
""
"let g:ale_cpp_ccls_init_options = {
"\   'cache': {
"\       'directory': '/tmp/ccls/cache'
"\   }
"\ }
"
" ----------------------------------------------------------------------
" deoplete-vim-lsp: vim lsp for deoplete
"----------------------------------------------------------------------

Plug 'prabirshrestha/async.vim'
" Plug 'prabirshrestha/vim-lsp'

" Plug 'lighttiger2505/deoplete-vim-lsp'

" call deoplete#custom#source('deoplete-vim-lsp', 'rank', 400)

" " Register ccls C++ lanuage server.
" if (executable('ccls'))
"    au User lsp_setup call lsp#register_server({
"       \ 'name': 'ccls',
"       \ 'cmd': {server_info->['ccls']},
"       \ 'root_uri': {server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'compile_commands.json'))},
"       \ 'initialization_options': {'cache': {'directory': '/tmp/ccls/cache' }},
"       \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp', 'cc'],
"       \ })
" endif

" " add rust lsp support (nightly toolchain)
" " rustup component add rls rust-analysis rust-src
" if (executable('rls'))
"     au User lsp_setup call lsp#register_server({
"         \ 'name': 'rls',
"         \ 'cmd': {server_info->['rustup', 'run', 'nightly', 'rls']},
"         \ 'workspace_config': {'rust': {'clippy_preference': 'on'}},
"         \ 'whitelist': ['rust'],
"         \ })
" endif

" " add python lsp support
" " pip install python-language-server
" if (executable('pyls'))
"     au User lsp_setup call lsp#register_server({
"         \ 'name': 'pyls',
"         \ 'cmd': {server_info->['pyls']},
"         \ 'whitelist': ['python'],
"         \ })
" endif

" " add golang lsp support
" " go get -u golang.org/x/tools/cmd/gopls
" "if (executable('gopls'))
" "    au User lsp_setup call lsp#register_server({
" "        \ 'name': 'gopls',
" "        \ 'cmd': {server_info->['gopls', '-mode', 'stdio']},
" "        \ 'whitelist': ['go'],
" "        \ })
" "    autocmd BufWritePre *.go LspDocumentFormatSync
" "endif
" "
" noremap <silent> <space>cd  :LspDefinition<cr>
" noremap <silent> <space>c<c-d>  :LspPeekDefinition<cr>
" noremap <silent> <space>cD  :LspDeclaration<cr>
" noremap <silent> <space>c<c-D>  :LspPeekDeclaration<cr>
" noremap <silent> <space>cr  :LspReference<cr>
" noremap <silent> <space>cR  :LspRename<cr>
" noremap <silent> <space>ci  :LspImplementation<cr>
" noremap <silent> <space>c<c-i>  :LspPeekImplementation<cr>
" noremap <silent> <space>cs  :LspWorkspaceSymbol<cr>
" noremap <silent> <space>cl  :LspDocumentSymbol<cr>
" "noremap <silent> <space>c


"----------------------------------------------------------------------
" echodoc：搭配 YCM/deoplete 在底部显示函数参数
"----------------------------------------------------------------------
" if index(g:bundle_group, 'echodoc') >= 0
" 	Plug 'Shougo/echodoc.vim'
" 	set noshowmode
" 	let g:echodoc#enable_at_startup = 1
" endif


"-------------------------------------
" COC
"-------------------------------------
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

if index(g:bundle_group, 'coc') >= 0
	Plug 'neoclide/coc.nvim', {'branch': 'release'}
	inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
	inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

	let g:coc_global_extensions = [
	  \'coc-clangd',
	  \'coc-lists',
      \'coc-markdownlint',
      \'coc-highlight',
      \'coc-vetur',
      \'coc-go',
      \'coc-pyright',
      \'coc-explorer',
      \'coc-json', 
      \'coc-git',
	  \'coc-fzf-preview',
	  \'coc-rust-analyzer',
      \]

	" Use <c-space> to trigger completion.
	if has('nvim')
		inoremap <silent><expr> <c-space> coc#refresh()
	else
		inoremap <silent><expr> <c-@> coc#refresh()
	endif

	" Make <CR> auto-select the first completion item and notify coc.nvim to
	" format on enter, <cr> could be remapped by other vim plugin
	inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
								\: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

	" Use `[g` and `]g` to navigate diagnostics
	" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
	nmap <silent> [g <Plug>(coc-diagnostic-prev)
	nmap <silent> ]g <Plug>(coc-diagnostic-next)

	" GoTo code navigation.
	nmap <silent><space>cd <Plug>(coc-definition)
	nmap <silent><space>cy <Plug>(coc-type-definition)
	nmap <silent><space>ci <Plug>(coc-implementation)
	nmap <silent><space>cr <Plug>(coc-references)

	" Use K to show documentation in preview window.
	nnoremap <silent> K :call <SID>show_documentation()<CR>
	" Symbol renaming.
	nmap <space>cr <Plug>(coc-rename)

	" Formatting selected code.
	xmap <space>cf  <Plug>(coc-format-selected)
	nmap <space>cf  <Plug>(coc-format-selected)

	augroup mygroup
	autocmd!
	" Setup formatexpr specified filetype(s).
	autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
	" Update signature help on jump placeholder.
	autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
	augroup end

	" Applying codeAction to the selected region.
	" Example: `<leader>aap` for current paragraph
	xmap <space>ca  <Plug>(coc-codeaction-selected)
	nmap <space>ca  <Plug>(coc-codeaction-selected)

	" Remap keys for applying codeAction to the current buffer.
	nmap <space>cA  <Plug>(coc-codeaction)
	" Apply AutoFix to problem on the current line.
	nmap <space>cF  <Plug>(coc-fix-current)

	" Map function and class text objects
	" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
	" xmap if <Plug>(coc-funcobj-i)
	" omap if <Plug>(coc-funcobj-i)
	" xmap af <Plug>(coc-funcobj-a)
	" omap af <Plug>(coc-funcobj-a)
	" xmap ic <Plug>(coc-classobj-i)
	" omap ic <Plug>(coc-classobj-i)
	" xmap ac <Plug>(coc-classobj-a)
	" omap ac <Plug>(coc-classobj-a)

	" Remap <C-f> and <C-b> for scroll float windows/popups.
	if has('nvim-0.4.0') || has('patch-8.2.0750')
		nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
		nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
		inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
		inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
		vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
		vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
	endif

	" Use CTRL-S for selections ranges.
	" Requires 'textDocument/selectionRange' support of language server.
	nmap <silent> <C-s> <Plug>(coc-range-select)
	xmap <silent> <C-s> <Plug>(coc-range-select)

	" Add `:Format` command to format current buffer.
	command! -nargs=0 Format :call CocAction('format')

	" Add `:Fold` command to fold current buffer.
	command! -nargs=? Fold :call     CocAction('fold', <f-args>)

	" Add `:OR` command for organize imports of the current buffer.
	command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

	" Add (Neo)Vim's native statusline support.
	" NOTE: Please see `:h coc-status` for integrations with external plugins that
	" provide custom statusline: lightline.vim, vim-airline.
	set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

	" Mappings for CoCList
	" Show all diagnostics.
	nnoremap <silent><nowait> <space>oc :<C-u>CocCommand<cr>
	nnoremap <silent><nowait> <space>or :<C-u>CocRestart<cr>
	nnoremap <silent><nowait> <space>oi :<C-u>CocList marketplace<cr>
	nnoremap <silent><nowait> <space>oA  :<C-u>CocList diagnostics<cr>
	" Manage extensions.
	nnoremap <silent><nowait> <space>oE  :<C-u>CocList extensions<cr>
	" Show commands.
	nnoremap <silent><nowait> <space>oC  :<C-u>CocList commands<cr>
	" Find symbol of current document.
	nnoremap <silent><nowait> <space>oO  :<C-u>CocList outline<cr>
	" Search workspace symbols.
	nnoremap <silent><nowait> <space>os  :<C-u>CocList -I symbols<cr>
	" Do default action for next item.
	nnoremap <silent><nowait> <space>oj  :<C-u>CocNext<CR>
	" Do default action for previous item.
	nnoremap <silent><nowait> <space>ok  :<C-u>CocPrev<CR>
	" Resume latest coc list.
	nnoremap <silent><nowait> <space>op  :<C-u>CocListResume<CR>

	" fzf-preview
	nmap <space>af [fzf-p]
	xmap <space>af [fzf-p]

	nnoremap <silent> [fzf-p]p     :<C-u>CocCommand fzf-preview.FromResources project_mru git<CR>
	nnoremap <silent> [fzf-p]gs    :<C-u>CocCommand fzf-preview.GitStatus<CR>
	nnoremap <silent> [fzf-p]ga    :<C-u>CocCommand fzf-preview.GitActions<CR>
	nnoremap <silent> [fzf-p]b     :<C-u>CocCommand fzf-preview.Buffers<CR>
	nnoremap <silent> [fzf-p]B     :<C-u>CocCommand fzf-preview.AllBuffers<CR>
	nnoremap <silent> [fzf-p]o     :<C-u>CocCommand fzf-preview.FromResources buffer project_mru<CR>
	nnoremap <silent> [fzf-p]<C-o> :<C-u>CocCommand fzf-preview.Jumps<CR>
	nnoremap <silent> [fzf-p]g;    :<C-u>CocCommand fzf-preview.Changes<CR>
	nnoremap <silent> [fzf-p]/     :<C-u>CocCommand fzf-preview.Lines --add-fzf-arg=--no-sort --add-fzf-arg=--query="'"<CR>
	nnoremap <silent> [fzf-p]*     :<C-u>CocCommand fzf-preview.Lines --add-fzf-arg=--no-sort --add-fzf-arg=--query="'<C-r>=expand('<cword>')<CR>"<CR>
	nnoremap          [fzf-p]gr    :<C-u>CocCommand fzf-preview.ProjectGrep<Space>
	xnoremap          [fzf-p]gr    "sy:CocCommand   fzf-preview.ProjectGrep<Space>-F<Space>"<C-r>=substitute(substitute(@s, '\n', '', 'g'), '/', '\\/', 'g')<CR>"
	nnoremap <silent> [fzf-p]t     :<C-u>CocCommand fzf-preview.BufferTags<CR>
	nnoremap <silent> [fzf-p]q     :<C-u>CocCommand fzf-preview.QuickFix<CR>
	nnoremap <silent> [fzf-p]l     :<C-u>CocCommand fzf-preview.LocationList<CR>

	"coc-explorer
	nnoremap <space>ae :<C-u>CocCommand explorer<CR>
endif


"----------------------------------------------------------------------
" LeaderF：CtrlP / FZF 的超级代替者，文件模糊匹配，tags/函数名 选择
"----------------------------------------------------------------------
if index(g:bundle_group, 'leaderf') >= 0
	" 如果 vim 支持 python 则启用  Leaderf
	if has('python') || has('python3')
		Plug 'Yggdroot/LeaderF'

		" CTRL+p 打开文件模糊匹配
		let g:Lf_ShortcutF = '<c-p>'

		" ALT+n 打开 buffer 模糊匹配
		let g:Lf_ShortcutB = '<m-n>'
		
		" <SPACE>+. doom emacs like config"
		noremap <space>fr :LeaderfMru<cr>
		" 
		" CTRL+n 打开最近使用的文件 MRU，进行模糊匹配
		" noremap <c-n> :LeaderfMru<cr>

		" ALT+p 打开函数列表，按 i 进入模糊匹配，ESC 退出
		noremap <space>sf :LeaderfFunction!<cr>
		"noremap <m-p> :LeaderfFunction!<cr>

		" ALT+SHIFT+p 打开 tag 列表，i 进入模糊匹配，ESC退出
		"noremap <m-P> :LeaderfBufTag!<cr>
		noremap <space>st :LeaderfBufTag!<cr>
		noremap <space>ff :LeaderfFile<cr>
		noremap <space>. :<c-U>Dirvish %:p:h<cr>

		noremap <space>< :LeaderfBuffer<cr>
		noremap <space>bb :LeaderfBuffer<cr>
		" ALT+n 打开 buffer 列表进行模糊匹配
		"noremap <m-n> :LeaderfBuffer<cr>

		" 全局 tags 模糊匹配
		"noremap <m-m> :LeaderfTag<cr>
		noremap <space>sm :LeaderfTag<cr>

		" 最大历史文件保存 2048 个
		let g:Lf_MruMaxFiles = 2048

		" ui 定制
		let g:Lf_StlSeparator = { 'left': '', 'right': '', 'font': '' }

		" 如何识别项目目录，从当前文件目录向父目录递归知道碰到下面的文件/目录
		let g:Lf_RootMarkers = ['.project', '.root', '.svn', '.git']
		let g:Lf_WorkingDirectoryMode = 'Ac'
		let g:Lf_WindowHeight = 0.30
		let g:Lf_CacheDirectory = expand('~/.vim/cache')

		" 显示绝对路径
		let g:Lf_ShowRelativePath = 0

		" 隐藏帮助
		let g:Lf_HideHelp = 1

		" 模糊匹配忽略扩展名
		let g:Lf_WildIgnore = {
					\ 'dir': ['.svn','.git','.hg'],
					\ 'file': ['*.sw?','~$*','*.bak','*.exe','*.o','*.so','*.py[co]']
					\ }

		" MRU 文件忽略扩展名
		let g:Lf_MruFileExclude = ['*.so', '*.exe', '*.py[co]', '*.sw?', '~$*', '*.bak', '*.tmp', '*.dll']
		let g:Lf_StlColorscheme = 'powerline'

		" 禁用 function/buftag 的预览功能，可以手动用 p 预览
		let g:Lf_PreviewResult = {'Function':0, 'BufTag':0}

		" 使用 ESC 键可以直接退出 leaderf 的 normal 模式
		let g:Lf_NormalMap = {
				\ "File":   [["<ESC>", ':exec g:Lf_py "fileExplManager.quit()"<CR>']],
				\ "Buffer": [["<ESC>", ':exec g:Lf_py "bufExplManager.quit()"<cr>']],
				\ "Mru": [["<ESC>", ':exec g:Lf_py "mruExplManager.quit()"<cr>']],
				\ "Tag": [["<ESC>", ':exec g:Lf_py "tagExplManager.quit()"<cr>']],
				\ "BufTag": [["<ESC>", ':exec g:Lf_py "bufTagExplManager.quit()"<cr>']],
				\ "Function": [["<ESC>", ':exec g:Lf_py "functionExplManager.quit()"<cr>']],
				\ }

	else
		" 不支持 python ，使用 CtrlP 代替
		Plug 'ctrlpvim/ctrlp.vim'

		" 显示函数列表的扩展插件
		Plug 'tacahiroy/ctrlp-funky'

		" 忽略默认键位
		let g:ctrlp_map = ''

		" 模糊匹配忽略
		let g:ctrlp_custom_ignore = {
		  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
		  \ 'file': '\v\.(exe|so|dll|mp3|wav|sdf|suo|mht)$',
		  \ 'link': 'some_bad_symbolic_links',
		  \ }

		" 项目标志
		let g:ctrlp_root_markers = ['.project', '.root', '.svn', '.git']
		let g:ctrlp_working_path = 0

		" CTRL+p 打开文件模糊匹配
		noremap <c-p> :CtrlP<cr>

		" CTRL+n 打开最近访问过的文件的匹配
		noremap <c-n> :CtrlPMRUFiles<cr>

		" ALT+p 显示当前文件的函数列表
		noremap <m-p> :CtrlPFunky<cr>

		" ALT+n 匹配 buffer
		noremap <m-n> :CtrlPBuffer<cr>
	endif
endif



"----------------------------------------------------------------------
" 结束插件安装
"----------------------------------------------------------------------
call plug#end()