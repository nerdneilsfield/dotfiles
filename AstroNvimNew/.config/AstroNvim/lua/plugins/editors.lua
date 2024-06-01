local function copy(lines, _) require("osc52").copy(table.concat(lines, "\n")) end

local function paste() return { vim.fn.split(vim.fn.getreg "", "\n"), vim.fn.getregtype "" } end
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
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = {
          mappings = {
            n = {
              ["<leader>cc"] = { "+yy", desc = "copy line" },
              ["<leader>cy"] = { "+y", desc = "copy" },
            },
          },
          options = {
            g = {
              clipboard = {
                -- name = "OSC 52",
                -- copy = {
                --   ["+"] = require("vim.clipboard.osc52").copy,
                --   ["*"] = require("vim.clipboard.osc52").copy,
                -- },
                -- paste = {
                --   ["+"] = require("vim.clipboard.osc52").paste,
                --   ["*"] = require("vim.clipboard.osc52").paste,
                -- },
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
