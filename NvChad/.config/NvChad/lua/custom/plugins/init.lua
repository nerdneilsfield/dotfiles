return {
{
    "nyoom-engineering/oxocarbon",
    lazy = false
}, 
-- {"onsails/lspkind.nvim",
-- lazy=false}, 
-- for first auth to github
-- {"github/copilot.vim",
-- 	lazy=false,
-- },
{
    "zbirenbaum/copilot.lua",
    config = function()
        vim.defer_fn(function()
            require("copilot").setup({
                cmp = {
                    enabled = true,
                    method = "getCompletionsCycling"
                }
            })
        end, 100)
    end,
}, 
{
	"zbirenbaum/copilot-cmp",
	after = "copilot.lua",
	config = function()
		require("copilot_cmp").setup()
	end,
},
-- -- ["liuchengxu/vista.vim"] = {},
-- ["jose-elias-alvarez/null-ls.nvim"] = {
-- 	after = "nvim-lspconfig",
-- 	config = function()
-- 		require("custom.plugins.configs.null-ls")
-- 	end,
-- },
{
    "tzachar/cmp-tabnine",
    after = "nvim-cmp",
    run = "./install.sh",
    config = function()
        require("custom.plugins.configs.tabnine")
    end
}, 
-- ["folke/which-key.nvim"] = {
-- 	disable = false,
-- 	keys = { "<leader>", "<localleader>" },
-- },
{
    "phaazon/hop.nvim",
    branch = "v1",
    event = "BufRead",
    config = function()
        -- you can configure Hop the way you like here; see :h hop-config
        require("hop").setup({
            keys = "etovxqpdygfblzhckisuran"
        })
    end
}, 
-- ["liuchengxu/vista.vim"] = {
-- 	event = "BufRead",
-- 	config = function() end,
-- },
-- --  ["xolox/vim-misc"] = {},
-- -- ["xolox/vim-easytags"] = {},
{
    "skywind3000/asynctasks.vim",
    config = function()
        vim.g.asyncrun_open = 10
    end
}, 
{"skywind3000/asyncrun.vim"},
-- ["ludovicchabant/vim-gutentags"] = {
-- 	config = function() end,
-- },
-- -- ["skywind3000/gutentags_plus"] = {
-- --     after = "vim-gutentags",
-- --     config = function()
-- --     end
-- -- },
{"mbbill/undotree"},
{
	"Pocco81/true-zen.nvim",
	cmd = { "TZAtaraxis", "TZMinimalist" },
	config = function()
		require("true-zen").setup()
	end,
},
-- ["gbprod/yanky.nvim"
-- 	config = function()
-- 		require("yanky").setup()
-- 	end,
-- },
{
	"ojroques/vim-oscyank",
	branch = "main",
},
{"hrsh7th/cmp-cmdline", lazy=false},
-- {"delphinus/cmp-ctags", lazy=false},
{"ray-x/cmp-treesitter", lazy=false},
{"kdheepak/cmp-latex-symbols", lazy=false},
{"neovim/nvim-lspconfig",
	after={"lspkind",  "delphinus/cmp-ctags", "ray-x/cmp-treesitter", "kdheepak/cmp-latex-symbols"},
	config = function()
		require("plugins.configs.lspconfig")
		require("custom.plugins.configs.lspconfig")
	end,
},
-- -- Override plugin definition options
-- ["goolord/alpha-nvim"
-- 	disable = false,
-- 	-- cmd = "Alpha",
-- },
-- --     ['nvim-tree/nvim-tree.lua'
-- --         override_options = function()
-- -- 		require'nvim-tree'.setup()
-- -- 	end
-- --         --     open_on_setup = true,
-- --         --     open_on_setup_file = true,
-- --         --     git = {
-- --         --         enable = true
-- --         --     },
-- --         --     renderer = {
-- --         --         highlight_git = true,
-- --         --         icons = {
-- --         --             show = {
-- --         --                 git = true
-- --         --             }
-- --         --         }
-- --         --     }
-- --         -- }
-- --     },
{"hrsh7th/nvim-cmp",
	opts = require("custom.plugins.configs.cmp"),
},
{
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
		"html", "css", "bash", "cpp", "c", "rust", "zig", 
		"toml", "yaml", "python", "go", "verilog", "scala", 
		"java", "vim", "vue", "latex", "bibtex", "cuda", 
		"cmake", "lua", "javascript", "typescript", "json"},
    },
  },
-- {"williamboman/mason.nvim",
-- 	opts = {
-- 		ensure_installed = { -- lua stuff
-- 			"lua-language-server",
-- 			"stylua", 
-- 			-- web dev
-- 			--   "css-lsp",
-- 			--   "html-lsp",
-- 			--   "typescript-language-server",
-- 			--   "deno",
-- 			--   "emmet-ls",
-- 			-- "json-lsp",
-- 			-- shell
-- 			"shfmt",
-- 			"shellcheck", -- c++/clang
-- 			-- "clang-format",
-- 			-- "clangd",
-- 			-- "cmake-language-server",
-- 			-- "cmakelang",
-- 			-- "cpplint",
-- 			"cpptools",
-- 			"codelldb", ---- zls
-- 			"zls", ---- python
-- 			-- "pyright",
-- 			-- "blue",
-- 			-- "isort",
-- 			-- "debugpy",
-- 			-- "vulture",
-- 			-- "pylint",
-- 			--- go
-- 			-- "gopls",
-- 			-- "golangci-lint",
-- 			-- "goimports",
-- 			-- "delve",
-- 			--- latex
-- 			-- "ltex-ls",
-- 			--- makrdown
-- 			"cbfmt",
-- 			"markdownlint",
-- 			"marksman", --- include some java
-- 			--- rust
-- 			-- "rust-analyzer",
-- 		},
-- 	},
-- },
}
