-- example file i.e lua/custom/init.lua
-- load your options globals, autocmds here or anything .__.
-- you can even override default options here (core/options.lua)
-- autocmd({ "BufAdd", "BufEnter" }, {
--   callback = function(args)
--     require("hop").setup(),
--   end,
-- })

--- gutentags && gutentags_plus
vim.g.gutentags_project_root = { ".root", ".svn", ".git", ".hg", ".project" }
vim.g.gutentags_ctags_tagfile = ".tags"
vim.g.gutentags_modules = { "ctags", "gtags_cscope" }
vim.g.gutentags_cache_dir = vim.fn.expand("~/.cache/tags")
vim.g.gutentags_ctags_extra_args = { "--fields=+niazS", "--extra=+q", "--c++-kinds=+px", "--c-kinds=+px", "--output-format=e-ctags" }
vim.g.gutentags_auto_add_gtags_cscope = 0
vim.g.gutentags_plus_switch = 1
vim.g.gutentags_plus_nomap = 1
-- --- async run
vim.g.asyncrun_open = 10
vim.g.asyncrun_rootmarks = { ".svn", ".git", ".root", "_darcs", "build.xml" }
--
local function map(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- map("n", "<leader>cps", ":GscopeFind s <C-R><C-W><cr>")
-- map("n", "<leader>cpg", ":GscopeFind g <C-R><C-W><cr>")
-- map("n", "<leader>cpc", ":GscopeFind c <C-R><C-W><cr>")
-- map("n", "<leader>cpt", ":GscopeFind t <C-R><C-W><cr>")
-- map("n", "<leader>cpe", ":GscopeFind e <C-R><C-W><cr>")
-- map("n", "<leader>cpf", ':GscopeFind f <C-R>=expand("<cfile>")<cr><cr>')
-- map("n", "<leader>cpi", ':GscopeFind i <C-R>=expand("<cfile>")<cr><cr>')
-- map("n", "<leader>cpd", ":GscopeFind d <C-R><C-W><cr>")
-- map("n", "<leader>cpa", ":GscopeFind a <C-R><C-W><cr>")
-- map("n", "<leader>cpz", ":GscopeFind z <C-R><C-W><cr>")
map("n", "<leader>cps", "<Plug>GscopeFindSymbol")
map("n", "<leader>cpg", "<Plug>GscopeFindDefinition")
map("n", "<leader>cpc", "<Plug>GscopeFindCallingFunc")
map("n", "<leader>cpt", "<Plug>GscopeFindText")
map("n", "<leader>cpe", "<Plug>GscopeFindEgrep")
map("n", "<leader>cpf", "<Plug>GscopeFindFile")
map("n", "<leader>cpi", "<Plug>GscopeFindInclude")
map("n", "<leader>cpd", "<Plug>GscopeFindCalledFunc")
map("n", "<leader>cpa", "<Plug>GscopeFindAssign")
map("n", "<leader>cpz", "<Plug>GscopeFindCtag")

-- yank
map("n", "<leader>y", "<Plug>OSCYank")

-- require("nvim-tree").setup()