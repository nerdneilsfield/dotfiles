-- Mapping data with "desc" stored directly by vim.keymap.set().
--
-- Please use this mappings table to set keyboard mapping since this is the
-- lower level configuration and more robust one. (which-key will
-- automatically pick-up stored data by this setting.)
return {
  -- first key is the mode
  n = {
    -- second key is the lefthand side of the map
    -- mappings seen under group name "Buffer"
    ["<leader><space>"] = { "<cmd> Telescope keymaps<CR>", desc = "show keymapping" },

    ["<leader>w"] = { name = "Window" },
    ["<leader>wh"] = { "<C-w>h", desc = "go to left window" },
    ["<leader>wl"] = { "<C-w>l", desc = "go to right window" },
    ["<leader>wj"] = { "<C-w>j", desc = "go to up window" },
    ["<leader>wk"] = { "<C-w>k", desc = "go to down window" },
    ["<leader>wv"] = { "<C-w>v", desc = "split window vertically" },
    ["<leader>ws"] = { "<C-w>s", desc = "split window horizontally" },
    ["<leader>wq"] = { "<C-w>q", desc = "close the window" },
    ["<leader>wm"] = { "<C-w>o", desc = "max the window" },
    ["<leader>wt"] = { "<cmd> TroubleToggle<CR>", desc = "toggle trouble" },
    ["<leader>wu"] = { "<cmd> UndotreeToggle<CR>", desc = "toggle undotree" },

    -- save file
    ["<leader>fs"] = { ":w <CR>", desc = "save the file" },

    ["<leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" },
    ["<leader>bD"] = {
      function()
        require("astronvim.utils.status").heirline.buffer_picker(
          function(bufnr) require("astronvim.utils.buffer").close(bufnr) end
        )
      end,
      desc = "Pick to close",
    },
    -- tables with the `name` key will be registered with which-key if it's installed
    -- this is useful for naming menus
    ["<leader>b"] = { name = "Buffers" },
    -- quick save
    -- ["<C-s>"] = { ":w!<cr>", desc = "Save File" },  -- change description but the same command

    ["<leader>j"] = { name = "Jump" },
    ["<leader>jw"] = { "<cmd> HopWord <CR>", desc = "jump to word" },
    ["<leader>jj"] = { "<cmd> HopChar1 <CR>", desc = "jump to char" },
    ["<leader>jJ"] = { "<cmd> HopChar2 <CR>", desc = "jump to 2 char" },
    ["<leader>jl"] = { "<cmd> HopLine <CR>", desc = "jump to line" },
    ["<leader>js"] = { "<cmd> lua require('telescope.builtin').lsp_document_symbols() <CR>", desc = "jump to symbols" },

    ["<leader>z"] = { name = "Zen Mode" },
    ["<leader>zf"] = { "<cmd> TZFocus <CR>", desc = "zen focus" },
    ["<leader>zm"] = { "<cmd> TZMinimalist <CR>", desc = "zen minimalist" },
    ["<leader>zn"] = { "<cmd> TZNarrow <CR>", desc = "zen narrow" },
    ["<leader>zv"] = { "<cmd> '<,'>TZNarrow <CR>", desc = "zen narrow" },
    ["<leader>za"] = { "<cmd> TZAtaraxis <CR>", desc = "zen ataraxis" },
    -- ["<leader>c"] = {
    --   require("osc52").copy_operator,
    --   expr = true,
    --   desc = "Copy",
    -- },
    -- ["<leader>cc"] = {
    --   "<leader>c_",
    --   desc = "Copy Line",
    --   remap = true,
    -- },
  },
  t = {
    -- setting a mapping to false will disable it
    -- ["<esc>"] = false,
  },
  v = {
    -- ["<leader>c"] = {
    --   require("osc52").copy_visual,
    --   expr = true,
    --   desc = "Copy",
    -- },
  },
}
