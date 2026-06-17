---@type LazySpec
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server",
        "stylua",
        "tree-sitter-cli",
        "texlab",
        "typescript-language-server",
        "eslint-lsp",
        "eslint_d",
        "prettierd",
        "docker-compose-language-service",
        "lemminx",
        "markdownlint",
        "yamllint",
      },
    },
  },
}
