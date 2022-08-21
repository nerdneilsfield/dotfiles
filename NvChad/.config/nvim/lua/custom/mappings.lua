-- lua/custom/mappings 
local M = {}

-- add this table only when you want to disable default keys
M.disabled = {
--   n = {
--       ["<leader>h"] = "",
--       ["<C-s>"] = ""
--   }
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
  }
}

return M

