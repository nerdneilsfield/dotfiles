local function copy(lines, _) require("osc52").copy(table.concat(lines, "\n")) end

local function paste() return { vim.fn.split(vim.fn.getreg "", "\n"), vim.fn.getregtype "" } end

return {
  {
    "kvrohit/mellow.nvim",
  },
  {
    "phaazon/hop.nvim",
    opts = function()
      require("hop").setup {
        keys = "etovxqpdygfblzhckisuran",
      }
    end,
    dependencies = {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["<Leader>ja"] = { function() require("hop").hint_anywhere() end, desc = "Jump to anywhere" },
            ["<Leader>jw"] = { function() require("hop").hint_words() end, desc = "Jump to word" },
            ["<Leader>jj"] = { function() require("hop").hint_char1() end, desc = "Jump to char" },
            ["<Leader>jl"] = { function() require("hop").hint_lines() end, desc = "Jump to line" },
            ["<Leader>jL"] = {
              function() require("hop").hint_lines_skip_whitespace() end,
              desc = "Jump to line (skip whitespace)",
            },
          },
        },
      },
    },
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
