-- Just an example, supposed to be placed in /lua/custom/

local M = {}

-- make sure you maintain the structure of `core/default_config.lua` here,
-- example of changing theme:

-- M.ui = {
--   theme = "gruvchad",
-- }

M.plugins = {
	user = require("custom.plugins"),
	override = {
		["hrsh7th/nvim-cmp"] = require("custom.plugins.configs.cmp"),
		["williamboman/mason.nvim"] = {
			ensure_installed = {
				-- lua stuff
				"lua-language-server",
				"stylua",

				-- web dev
				--   "css-lsp",
				--   "html-lsp",
				--   "typescript-language-server",
				--   "deno",
				--   "emmet-ls",
				"json-lsp",

				-- shell
				"shfmt",
				"shellcheck",

				-- c++/clang
				"clang-format",
				"clangd",
				"cmake-language-server",
				"cmakelang",
				"cpplint",
				"cpptools",
				"codelldb",

				---- zls
				"zls",

				---- python
				"pyright",
				"blue",
				"isort",
				"debugpy",
				"vulture",
				"pylint",

				--- go
				"gopls",
				"golangci-lint",
				"goimports",
				"delve",

				--- latex
				"ltex-ls",

				--- makrdown
				"cbfmt",
				"markdownlint",
				"marksman",

				--- rust
				"rust-analyzer",
			},
		},
		-- ["NvChad/ui"] = {
		-- 	statusline = {
		-- 		separator_style = "round",
		-- 		overriden_modules = function()
		-- 			return require("custom.plugins.configs.vista")
		-- 		end,
		-- 	},
		-- },
	},
}

-- chadrc
M.mappings = require("custom.mappings")

return M
