return {
  {
    "kvrohit/mellow.nvim",
  },
  {
    "AstroNvim/astrocore",
    opts = {
      mappings = {
        n = {
          ["<Leader>ccc"] = { "+yy", desc = "Copy line" },
          ["<Leader>ccy"] = { "+y", desc = "Copy" },
          ["<Leader>cca"] = { 'ggVG"+y', desc = "Copy all" },
        },
        v = {
          ["<Leader>ccc"] = { "+yy", desc = "Copy line" },
          ["<Leader>ccy"] = { "+y", desc = "Copy" },
          ["<Leader>cca"] = { 'ggVG"+y', desc = "Copy all" },
        },
      },
      options = {
        g = {
          -- Neovim 0.10+ 内置 OSC52，替代已过时的 ojroques/nvim-osc52
          clipboard = "osc52",
        },
      },
    },
  },
}
