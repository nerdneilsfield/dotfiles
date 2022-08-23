return {
	["neovim/nvim-lspconfig"] = {
		config = function()
			require("plugins.configs.lspconfig")
			require("custom.plugins.configs.lspconfig")
		end,
	},
	-- for first auth to github
	-- ["github/copilot.vim"] = {},
	["zbirenbaum/copilot.lua"] = {
		config = function()
			vim.defer_fn(function()
				require("copilot").setup({
					cmp = {
						enabled = true,
						method = "getCompletionsCycling",
					},
				})
			end, 100)
		end,
	},
	["zbirenbaum/copilot-cmp"] = {},
	-- ["liuchengxu/vista.vim"] = {},
	["jose-elias-alvarez/null-ls.nvim"] = {
		after = "nvim-lspconfig",
		config = function()
			require("custom.plugins.configs.null-ls")
		end,
	},
	["folke/which-key.nvim"] = {
		disable = false,
		keys = { "<leader>", "<localleader>" },
	},

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

			---- zls
			"zls",
		},
	},
}
