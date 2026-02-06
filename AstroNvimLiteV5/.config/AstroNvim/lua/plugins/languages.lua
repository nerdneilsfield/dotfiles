---@type LazySpec
return {
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      servers = {
        "jsonls",
        "taplo",
        "yamlls",
        "dockerls",
        "docker_compose_language_service",
        "marksman",
        "lemminx",
      },
    },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        markdown = { "prettierd" },
        json = { "prettierd" },
        jsonc = { "prettierd" },
        toml = { "taplo" },
        yaml = { "prettierd" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        markdown = { "markdownlint" },
        yaml = { "yamllint" },
      },
    },
  },
}
