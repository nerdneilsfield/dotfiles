-- customize mason plugins
return {
  -- use mason-lspconfig to configure LSP installations
  {
    "williamboman/mason-lspconfig.nvim",
    -- overrides `require("mason-lspconfig").setup(...)`
    opts = function(_, opts)
      -- add more things to the ensure_installed table protecting against community packs modifying it
      opts.ensure_installed = require("astronvim.utils").list_insert_unique(opts.ensure_installed, {
        "lua_ls",
        "pyright",
        "clangd",
        "jsonls",
        "html",
        "tsserver",
        "yamlls",
        "cssls",
        "gopls",
        "golangci_lint_ls",
        -- "svls",
        "verible",
        -- "zls",
        "bashls",
        "rust_analyzer",
        "denols",
        "ltex",
        "texlab",
        "java_language_server",
        "docker_compose_language_service",
        "dockerls",
        -- "asm_lsp",
        "opencl_ls",
        "bufls",
      })
    end,
  },
  -- use mason-null-ls to configure Formatters/Linter installation for null-ls sources
  {
    "jay-babu/mason-null-ls.nvim",
    -- overrides `require("mason-null-ls").setup(...)`
    opts = function(_, opts)
      -- add more things to the ensure_installed table protecting against community packs modifying it
      opts.ensure_installed = require("astronvim.utils").list_insert_unique(opts.ensure_installed, {
        "prettier",
        "stylua",
        "isort",
        "black",
        "pylint",
        "clang-format",
        "cmakelang",
        "cmakelint",
        "cpplint",
        "rustfmt",
        "golangci-lint",
        "gospel",
        "gofumpt",
        "goimports",
        "goimports-reviser",
        "golines",
        "gotests",
        "gomodifytags",
        "jsonlint",
        "gersemi",
        "ruff",
        "shellcheck",
        "latexindent",
        "marksman",
        "volar",
        "taplo",
        -- "google-java-format",
        "gitlint",
        "buf",
      })
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    -- overrides `require("mason-nvim-dap").setup(...)`
    opts = function(_, opts)
      -- add more things to the ensure_installed table protecting against community packs modifying it
      opts.ensure_installed = require("astronvim.utils").list_insert_unique(opts.ensure_installed, {
        "python",
        "js",
        "cppdbg",
        "debugpy",
        "go",
        "delve",
        "codelldb",
      })
    end,
  },
}
