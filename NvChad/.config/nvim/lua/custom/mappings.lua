-- lua/custom/mappings 
local M = {}

-- add this table only when you want to disable default keys
M.disabled = {
  n = {
      ["<leader>h"] = "",
    --   ["<C-s>"] = ""
  }
}

-- M.abc = {

--   n = {
--      ["<C-n>"] = {"<cmd> Telescope <CR>", "Open Telescope"}
--   }

--   i = {
--     -- more keys!
--   }
-- }

M.file = {
  n = {
    ["<leader>fs"] = {":w <CR>", "Save file"},
    ["jk"] = { "<ESC>", "escape insert mode" , opts = { nowait = true }},
    ["<leader><space>"] = {"<cmd> Telescope keymaps<CR>", "show keymapping"},
    -- ["<leader>w"] = {"<C-w>", "manager the window"},
    ["<leader>wh"] = {"<C-w>h", "go to left window"},
    ["<leader>wl"] = {"<C-w>l", "go to right window"},
    ["<leader>wj"] = {"<C-w>j", "go to up window"},
    ["<leader>wk"] = {"<C-w>k", "go to down window"},
    ["<leader>wv"] = {"<C-w>v", "split window vertically"},
    ["<leader>ws"] = {"<C-w>s", "split window horizontally"},
    ["<leader>wq"] = {"<C-w>q", "close the window"},
  }}

M.nvterm = {
    n = {
    ["<leader>wti"] = {
        function()
          require("nvterm.terminal").toggle "float"
        end,
        "toggle floating term",
      },
      ["<leader>wth"] = {
        function()
          require("nvterm.terminal").toggle "horizontal"
        end,
        "toggle horizontal term",
      },
      ["<leader>wtv"] = {
        function()
          require("nvterm.terminal").toggle "vertical"
        end,
        "toggle vertical term",
      },
  }
}

return M

