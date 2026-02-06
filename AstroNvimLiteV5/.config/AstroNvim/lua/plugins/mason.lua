---@type LazySpec
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server",
        "stylua",
        "tree-sitter-cli",
        "json-lsp",
        "taplo",
        "yaml-language-server",
        "yamllint",
        "dockerfile-language-server",
        "docker-compose-language-service",
        "marksman",
        "lemminx",
        "markdownlint",
        "prettierd",
      },
    },
  },
}
