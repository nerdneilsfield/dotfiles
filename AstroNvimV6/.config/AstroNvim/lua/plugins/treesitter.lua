---@type LazySpec
return {
  "AstroNvim/astrocore",
  opts = {
    treesitter = {
      ensure_installed = {
        "javascript",
        "typescript",
        "tsx",
        "xml",
      },
    },
  },
}
