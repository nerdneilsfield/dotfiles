-- lua/custom/mappings
local M = {}

-- add this table only when you want to disable default keys
M.disabled = {
	n = {
		["<leader>h"] = "",
		["<leader>e"] = "",
		--   ["<C-s>"] = ""
	},
}

-- M.abc = {

--   n = {
--      ["<C-n>"] = {"<cmd> Telescope <CR>", "Open Telescope"}
--   }

--   i = {
--     -- more keys!
--   }
-- }

M.file = {
	n = {
		["<leader>fs"] = { ":w <CR>", "Save file" },
		["jk"] = { "<ESC>", "escape insert mode", opts = { nowait = true } },
		["<leader><space>"] = { "<cmd> Telescope keymaps<CR>", "show keymapping" },
		-- ["<leader>w"] = {"<C-w>", "manager the window"},
		["<leader>wh"] = { "<C-w>h", "go to left window" },
		["<leader>wl"] = { "<C-w>l", "go to right window" },
		["<leader>wj"] = { "<C-w>j", "go to up window" },
		["<leader>wk"] = { "<C-w>k", "go to down window" },
		["<leader>wv"] = { "<C-w>v", "split window vertically" },
		["<leader>ws"] = { "<C-w>s", "split window horizontally" },
		["<leader>wq"] = { "<C-w>q", "close the window" },
		["<leader>wm"] = { "<C-w>o", "max the window" },
		["<leader>wt"] = { "<cmd> NvimTreeToggle <CR>", "toggle the tree" },
		["<leader>we"] = { "<cmd> NvimTreeFocus <CR>", "focus the tree" },
	},
}

M.nvterm = {
	n = {
		["<leader>wti"] = {
			function()
				require("nvterm.terminal").toggle("float")
			end,
			"toggle floating term",
		},
		["<leader>wth"] = {
			function()
				require("nvterm.terminal").toggle("horizontal")
			end,
			"toggle horizontal term",
		},
		["<leader>wtv"] = {
			function()
				require("nvterm.terminal").toggle("vertical")
			end,
			"toggle vertical term",
		},
	},
}

M.hop = {
	n = {
		-- ["f"] = {
		-- 	"<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true })<cr>",
		-- 	"hint after cursor",
		-- },
		-- ["F"] = {
		-- 	"<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true })<cr>",
		-- 	"hint before cursor",
		-- },
		-- ["t"] = {
		-- 	"<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })<cr>",
		-- 	"hint after cursor(R)",
		-- },
		-- ["T"] = {
		-- 	"<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true, hint_offset = -1 })<cr>",
		-- 	"hint before cursor(R)",
		-- },
		["<leader>jw"] = { "<cmd> HopWord <CR>", "jump to word" },
		["<leader>jj"] = { "<cmd> HopChar1 <CR>", "jump to char" },
		["<leader>jl"] = { "<cmd> HopLine <CR>", "jump to line" },
		["<leader>js"] = { "<cmd> lua require('telescope.builtin').lsp_document_symbols() <CR>", "jump to symbols" },
	},
}

M.vista = {
	n = {
		["<leader>wcv"] = { "<cmd> Vista!! <CR>", "open tags window" },
		["<leader>ct"] = { "<cmd> Vista!! <CR>", "open tags window" },
	},
}

M.undotree = {
	n = {
		["<leader>wu"] = { "<cmd> UndotreeToggle<CR>", "toggle undotree" },
	},
}

M.truezen = {
	n = {
		["<leader>zf"] = { "<cmd> TZFocus <CR>", "zen focus" },
		["<leader>zm"] = { "<cmd> TZMinimalist <CR>", "zen minimalist" },
		["<leader>zn"] = { "<cmd> TZNarrow <CR>", "zen narrow" },
		["<leader>zv"] = { "<cmd> '<,'>TZNarrow <CR>", "zen narrow" },
		["<leader>za"] = { "<cmd> TZAtaraxis <CR>", "zen ataraxis" },
	},
}

 M.gutentags = {
	n = {
-- 		["<leader>cps"] = { "<cmd> GscopeFind s expand('<cword>') <CR>", "Find symbol (reference) under cursor" },
-- 		["<leader>cpg"] = { "<cmd> GscopeFind g expand('<cword>') <CR>", "Find symbol definition under cursor" },
-- 		["<leader>cpc"] = { "<cmd> GscopeFind c <C-R><C-W> <CR>", "Functions calling by this function" },
-- 		["<leader>cpt"] = { "<cmd> GscopeFind t <C-R><C-W> <CR>", "Find text string under cursor" },
-- 		["<leader>cpe"] = { "<cmd> GscopeFind e <C-R><C-W> <CR>", "Find egrep pattern under cursor" },
-- 		["<leader>cpf"] = { "<cmd> GscopeFind f <C-R><C-R>=expand('<cfile>') <CR> <CR>", "Find file name under cursor" },
-- 		["<leader>cpi"] = {
-- 			"<cmd> GscopeFind i <C-R><C-R>=expand('<cfile>') <CR>",
-- 			"Find files #including the file name under cursor",
-- 		},
-- 		["<leader>cpd"] = { "<cmd> GscopeFind d <C-R><C-W> <CR>", "Functions called by this function" },
-- 		["<leader>cpa"] = { "<cmd> GscopeFind a <C-R><C-W> <CR>", "Find places where current symbol is assigned" },
-- 		["<leader>cpz"] = { "<cmd> GscopeFind z <C-R><C-W> <CR>", "Find current word in ctags database" },
		["<leader>cpu"] = { "<cmd> GutentagsUpdate <CR>", "Update tags" },
		["<leader>cpk"] = { "<cmd> GscopeKill <CR>", "Kill Cscope" },
	},
}

return M
