local function copy(lines, _) require("osc52").copy(table.concat(lines, "\n")) end

local function paste() return { vim.fn.split(vim.fn.getreg "", "\n"), vim.fn.getregtype "" } end

return {
  {
    "kvrohit/mellow.nvim",
  },
  {
    "ojroques/nvim-osc52",
    dependencies = {
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
              clipboard = {
                name = "osc52",
                copy = { ["+"] = copy, ["*"] = copy },
                paste = { ["+"] = paste, ["*"] = paste },
              },
            },
          },
        },
      },
    },
    config = function()
      require("osc52").setup {
        max_length = 0,
        silent = false,
        trim = false,
        tmux_passthrough = false,
      }
    end,
  },
}
