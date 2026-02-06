---@type LazySpec
return {
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      servers = {
        "bashls",
        "clangd",
        "gopls",
        "pyright",
        "rust_analyzer",
        "texlab",
        "ts_ls",
        "jsonls",
        "taplo",
        "dockerls",
        "docker_compose_language_service",
        "marksman",
        "lemminx",
        "yamlls",
      },
    },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        c = { "clang_format" },
        cpp = { "clang_format" },
        go = { "gofumpt", "goimports" },
        javascript = { "prettierd" },
        javascriptreact = { "prettierd" },
        typescript = { "prettierd" },
        typescriptreact = { "prettierd" },
        markdown = { "prettierd" },
        json = { "prettierd" },
        jsonc = { "prettierd" },
        toml = { "taplo" },
        yaml = { "prettierd" },
        python = { "black" },
        rust = { "rustfmt" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        c = { "clangtidy" },
        cpp = { "clangtidy" },
        go = { "golangcilint" },
        javascript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        markdown = { "markdownlint" },
        python = { "ruff" },
        yaml = { "yamllint" },
      },
    },
  },
}
