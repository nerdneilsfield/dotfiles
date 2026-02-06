-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "vimdoc",
      "markdown",
      "markdown_inline",
      "json",
      "jsonc",
      "toml",
      "yaml",
      "xml",
      "dockerfile",
    },
  },
}
