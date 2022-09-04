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
	["tzachar/cmp-tabnine"] = {
		after = "nvim-cmp",
		run = "./install.sh",
		config = function()
			require("custom.plugins.configs.tabnine")
		end,
	},
	["folke/which-key.nvim"] = {
		disable = false,
		keys = { "<leader>", "<localleader>" },
	},

	["phaazon/hop.nvim"] = {
		branch = "v1",
		event = "BufRead",
		config = function()
			-- you can configure Hop the way you like here; see :h hop-config
			require("hop").setup({ keys = "etovxqpdygfblzhckisuran" })
		end,
	},

	["liuchengxu/vista.vim"] = {
		event = "BufRead",
		config = function() end,
	},
  ["xolox/vim-misc"] = {},
	["xolox/vim-easytags"] = {},
  ["skywind3000/asynctasks.vim"] = {
    config = function()
      vim.g.asyncrun_open=10
    end,
  },
  ["skywind3000/asyncrun.vim"] = {},
	["mbbill/undotree"] = {},
	["Pocco81/true-zen.nvim"] = {
		config = function()
			require("true-zen").setup()
		end,
	},
	-- ["williamboman/mason.nvim"] = {
	-- 	ensure_installed = {
	-- 		-- lua stuff
	-- 		"lua-language-server",
	-- 		"stylua",
	--
	-- 		-- web dev
	-- 		--   "css-lsp",
	-- 		--   "html-lsp",
	-- 		--   "typescript-language-server",
	-- 		--   "deno",
	-- 		--   "emmet-ls",
	-- 		"json-lsp",
	--
	-- 		-- shell
	-- 		"shfmt",
	-- 		"shellcheck",
	--
	-- 		-- c++/clang
	-- 		"clang-format",
	-- 		"clangd",
	-- 		"cmake-language-server",
	-- 		"cmakelang",
	-- 		"cpplint",
	-- 		"cpptools",
	--
	-- 		---- zls
	-- 		"zls",
	-- 	},
	-- },
}
