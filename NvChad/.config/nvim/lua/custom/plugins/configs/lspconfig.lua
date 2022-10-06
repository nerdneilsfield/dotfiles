local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require("lspconfig")
local servers = {
	"zls",
	"cssls",
	"html",
  "jsonls",
	"clangd",
	"cmake",
	"pyright",
	"gopls",
	"ltex",
	"tsserver",
	"svlangserver",
	"rust_analyzer",
	"sourcery",
	"volar",
}

for _, lsp in ipairs(servers) do
	lspconfig[lsp].setup({
		on_attach = on_attach,
		capabilities = capabilities,
	})
end
