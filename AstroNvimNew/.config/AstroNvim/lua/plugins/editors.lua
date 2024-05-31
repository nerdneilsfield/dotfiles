return {
  {
    "kvrohit/mellow.nvim",
    -- lazy = false,
  },

  {
    "phaazon/hop.nvim",
    opts = function()
      -- you can configure Hop the way you like here; see :h hop-config
      require("hop").setup {
        keys = "etovxqpdygfblzhckisuran",
      }
    end,
    dependencies = {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["<leader>ja"] = { function() require("hop").hint_anywhere() end, desc = "jump to anywhere" },
            ["<leader>jw"] = { function() require("hop").hint_words() end, desc = "jump to word" },
            ["<leader>jj"] = { function() require("hop").hint_char1() end, desc = "jump to char" },
            -- ["<leader>jJ"] = { "<cmd> HopChar2 <CR>", desc = "jump to 2 char" },
            ["<leader>jl"] = { function() require("hop").hint_lines() end, desc = "jump to line" },
            ["<leader>jL"] = { function() require("hop").hint_lines_skip_whitespace() end, desc = "jump to line" },
          },
        },
      },
    },
  },
  {
    "ojroques/nvim-osc52",
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
