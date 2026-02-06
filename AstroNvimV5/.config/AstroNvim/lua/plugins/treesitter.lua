-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "bash",
      "c",
      "cpp",
      "go",
      "gomod",
      "gosum",
      "gowork",
      "javascript",
      "json",
      "jsonc",
      "dockerfile",
      "markdown",
      "markdown_inline",
      "lua",
      "python",
      "rust",
      "toml",
      "tsx",
      "typescript",
      "xml",
      "yaml",
      "vimdoc",
      "vim",
      "latex",
    },
  },
}
