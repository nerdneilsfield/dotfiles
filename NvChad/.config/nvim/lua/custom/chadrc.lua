-- Just an example, supposed to be placed in /lua/custom/

local M = {}

-- make sure you maintain the structure of `core/default_config.lua` here,
-- example of changing theme:

-- M.ui = {
--   theme = "gruvchad",
-- }

M.plugins = {
  user = require "custom.plugins",
  override = {
    ["hrsh7th/nvim-cmp"] = require "custom.plugins.configs.cmp",
    ["williamboman/mason.nvim"] = {
        ensure_installed = {
            -- lua stuff
            "lua-language-server",
            "stylua",

            -- web dev
            --   "css-lsp",
            --   "html-lsp",
            --   "typescript-language-server",
            --   "deno",
            --   "emmet-ls",
            "json-lsp",

            -- shell
            "shfmt",
            "shellcheck",

            -- c++/clang
            "clang-format",
            "clangd",
            "cmake-language-server",
            "cmakelang",
            "cpplint",
            "cpptools",

            ---- zls
            "zls"
        },
    },
  }
}

-- chadrc
M.mappings = require "custom.mappings"

return M
