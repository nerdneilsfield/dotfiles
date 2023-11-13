local source_mapping = {
	buffer = "[Buffer]",
	nvim_lsp = "[LSP]",
	nvim_lua = "[Lua]",
	cmp_tabnine = "[TN]",
	path = "[Path]",
	copilot = "[Copilot]",
	cmdline = "[Cmd]",
	ctags = "[🔧]",
	latex_symbols = "[Latex]",
	treesitter = "[🌲]",
}
require("luasnip/loaders/from_vscode").lazy_load()

local check_backspace = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
end

local function has_words_before()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
end

return {
  {"hrsh7th/nvim-cmp",
  dependencies = {
    "onsails/lspkind.nvim",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-nvim-lua",
    "ray-x/cmp-treesitter",
    "saadparwaiz1/cmp_luasnip",
    "hrsh7th/cmp-emoji",
    "delphinus/cmp-ctags",
    "jc-doyle/cmp-pandoc-references",

    "kdheepak/cmp-latex-symbols",
    {
          "zbirenbaum/copilot.lua",
          config = function()
            require("copilot").setup({
              suggestion = { enabled = false },
              panel = { enabled = false },
            })
          end,
    },
    {
        "zbirenbaum/copilot-cmp",
          -- "github/copilot.vim",
          cmd = "Copilot",
          event = "InsertEnter",
          config = function()
              require("copilot_cmp").setup({})
          end,
    },
    {
    "tzachar/cmp-tabnine",
    build = './install.sh',
    }, 

  },
  opts = function(_, opts)
    local cmp = require "cmp"
    local luasnip = require "luasnip"
    local astronvim = require("astronvim.utils")
    return astronvim.extend_tbl(opts, {
      completion = {
        completeopt = "menu,menuone,noinsert",
      },
      window = {
        documentation = {
          max_width = 40,
        },
        completion = {
            border = "rounded",
            winhighlight = "NormalFloat:Pmenu,NormalFloat:Pmenu,CursorLine:PmenuSel,Search:None",
        },
      },
      experimental = {
        ghost_text = true,
      },
      formatting = {
		-- format = lspkind.cmp_format({
		-- 	mode = "symbol",
		-- 	max_width = 50,
		-- 	symbol_map = {
		--       Copilot = "",
		--       TabNine = "💡",
		--     },
		--  }),
		format = function(entry, vim_item)
			-- if you have lspkind installed, you can use it like
			-- in the following line:
			vim_item.kind = require("lspkind").symbolic(vim_item.kind, { mode = "symbol" })
			vim_item.menu = source_mapping[entry.source.name]
			if entry.source.name == "cmp_tabnine" then
				local detail = (entry.completion_item.data or {}).detail
				vim_item.kind = "[]"
				if detail and detail:find(".*%%.*") then
					vim_item.kind = vim_item.kind .. " " .. detail
				end

				if (entry.completion_item.data or {}).multiline then
					vim_item.kind = vim_item.kind .. " " .. "[ML]"
				end
			end
			local maxwidth = 80
			vim_item.abbr = string.sub(vim_item.abbr, 1, maxwidth)
			return vim_item
		end,
	},
	sources = {
        {
            name = "copilot",
            -- keyword_length = 0,
            max_item_count = 3,
            trigger_characters = {
                {
                    ".",
                    ":",
                    "(",
                    "'",
                    '"',
                    "[",
                    ",",
                    "#",
                    "*",
                    "@",
                    "|",
                    "=",
                    "-",
                    "{",
                    "/",
                    "\\",
                    "+",
                    "?",
                    " ",
                    -- "\t",
                    -- "\n",
                    },
            },
            group_index = 1,
        },
        { name = "cmp_tabnine" },
        { name = "luasnip" },
		{
            name = "nvim_lsp",
            filter = function(entry, ctx)
                local kind = require("cmp.types.lsp").CompletionItemKind[entry:get_kind()]
                if kind == "Snippet" and ctx.prev_context.filetype == "java" then
                return true
                end

                if kind == "Text" then
                return true
                end
            end,
            group_index = 2,
        },
		{ name = "ctags" },
		{ name = "treesitter" },
		{ name = "buffer" },
		{ name = "nvim_lua" },
		{ name = "cmdline"},
		{ name = "path" },
		{ name = "latex_symbols" },
	},
      mapping = {
        ["<C-p>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Select },
        ["<C-n>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Select },
        ["<C-k>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Select },
        ["<C-j>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Select },
        -- ["<Tab>"] = cmp.mapping(function(fallback)
        --   if luasnip.jumpable(1) then
        --     luasnip.jump(1)
        --   else
        --     fallback()
        --   end
        -- end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<Tab>"] = vim.schedule_wrap(function(fallback)
            if cmp.visible() and has_words_before() then
                cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
            elseif luasnip.jumpable(1) then
                luasnip.jump(1)
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            elseif luasnip.expandable() then
                luasnip.expand()
            elseif check_backspace() then
                -- cmp.complete()
                fallback()
            else 
                fallback()
            end
        end),
        ["<CR>"] = cmp.mapping.confirm({
            -- this is the important line
            behavior = cmp.ConfirmBehavior.Replace,
            select = false,
        }),
      },
      comparators = {
        require("copilot_cmp.comparators").prioritize,

        -- Below is the default comparitor list and order for nvim-cmp
        cmp.config.compare.offset,
        -- cmp.config.compare.scopes, --this is commented in nvim-cmp too
        cmp.config.compare.exact,
        cmp.config.compare.score,
        cmp.config.compare.recently_used,
        cmp.config.compare.locality,
        cmp.config.compare.kind,
        cmp.config.compare.sort_text,
        cmp.config.compare.length,
        cmp.config.compare.order,
      },
    })
  end,
 }
}