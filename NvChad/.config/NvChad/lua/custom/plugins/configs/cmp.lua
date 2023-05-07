local present, lspkind = pcall(require, "lspkind")

if not present then
	return
end

local source_mapping = {
	buffer = "[Buffer]",
	nvim_lsp = "[LSP]",
	nvim_lua = "[Lua]",
	cmp_tabnine = "[TN]",
	path = "[Path]",
	copilot = "[]",
	cmdline = "[Cmd]",
	ctags = "[🔧]",
	latex_symbols = "[Latex]",
	treesitter = "[🌲]",
}

return {
	-- preselect = cmp.PreselectMode.None,
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
			vim_item.kind = lspkind.symbolic(vim_item.kind, { mode = "symbol" })
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
		{ name = "cmp_tabnine" },
		{ name = "copilot" },
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "ctags" },
		{ name = "treesitter" },
		{ name = "buffer" },
		{ name = "nvim_lua" },
		{ name = "cmdline"},
		{ name = "path" },
		{ name = "latex_symbols" },
	},
}
