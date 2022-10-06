local present, null_ls = pcall(require, "null-ls")

if not present then
	return
end

local b = null_ls.builtins

local sources = {

	-- webdev stuff
	--    b.formatting.deno_fmt,
	--    b.formatting.prettier,

	-- Lua
	b.formatting.stylua,

	-- json
	null_ls.builtins.formatting.json_tool,

	-- c++
	b.formatting.clang_format,
	b.formatting.cmake_format,
	b.formatting.gersemi,
	b.diagnostics.cppcheck,
	-- b.diagnostics.checkmake,
	b.diagnostics.cpplint,
	-- null_ls.builtins.diagnostics.clang_check,

	-- python
	null_ls.builtins.diagnostics.vulture,
	null_ls.builtins.formatting.blue,
	null_ls.builtins.formatting.isort,
	-- null_ls.builtins.code_actions.refactoring,

	-- rust
	null_ls.builtins.formatting.rustfmt,

	-- go
	null_ls.builtins.formatting.gofmt,
	null_ls.builtins.formatting.gofumpt,
	null_ls.builtins.formatting.goimports,
	-- null_ls.builtins.formatting.goimports_reviser,

	-- Shell
	-- b.formatting.shfmt,
	b.diagnostics.shellcheck.with({ diagnostics_format = "#{m} [#{c}]" }),

	-- zsh
	null_ls.builtins.diagnostics.zsh,

	-- markdown
	null_ls.builtins.diagnostics.markdownlint,
	null_ls.builtins.formatting.cbfmt,
}

null_ls.setup({
	debug = true,
	sources = sources,
})
