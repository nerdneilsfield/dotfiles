return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        n = {
          ["<Leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" },
          ["<Leader>bD"] = {
            function()
              require("astroui.status.heirline").buffer_picker(function(bufnr) require("astrocore.buffer").close(bufnr) end)
            end,
            desc = "Pick to close",
          },
          ["<Leader>bQ"] = {
            function() require("astrocore.buffer").close(vim.fn.bufnr(vim.fn.expand "%"), true) end,
            desc = "Force close buffer",
          },

          ["<Leader>c"] = { desc = "Cursor" },
          ["<Leader>z"] = { desc = "Zen Mode" },
          ["<Leader>j"] = { desc = "Jump" },
          ["<Leader>ja"] = { function() require("flash").jump() end, desc = "Flash jump" },
          ["<Leader>jj"] = { function() require("flash").jump() end, desc = "Flash jump" },
          ["<Leader>jt"] = { function() require("flash").treesitter() end, desc = "Flash Treesitter" },
          ["<Leader>js"] = {
            function()
              local ok, snacks = pcall(require, "snacks")
              if ok and snacks.picker and snacks.picker.lsp_symbols then
                snacks.picker.lsp_symbols()
              else
                vim.lsp.buf.document_symbol()
              end
            end,
            desc = "Jump to symbols",
          },
          ["<Leader><Space>"] = {
            function()
              local ok, snacks = pcall(require, "snacks")
              if ok and snacks.picker and snacks.picker.keymaps then
                snacks.picker.keymaps()
              else
                vim.cmd "map"
              end
            end,
            desc = "Show keymapping",
          },

          ["<Leader>w"] = { desc = "Window" },
          ["<Leader>wh"] = { "<C-w>h", desc = "Go to left window" },
          ["<Leader>wl"] = { "<C-w>l", desc = "Go to right window" },
          ["<Leader>wj"] = { "<C-w>j", desc = "Go to up window" },
          ["<Leader>wk"] = { "<C-w>k", desc = "Go to down window" },
          ["<Leader>wv"] = { "<C-w>v", desc = "Split window vertically" },
          ["<Leader>ws"] = { "<C-w>s", desc = "Split window horizontally" },
          ["<Leader>wq"] = { "<C-w>q", desc = "Close the window" },
          ["<Leader>wm"] = { "<C-w>o", desc = "Max the window" },
          ["<Leader>wt"] = {
            function()
              if vim.fn.exists(":Trouble") == 2 then
                vim.cmd "Trouble diagnostics toggle"
              end
            end,
            desc = "Toggle trouble",
          },
          ["<Leader>wu"] = { "<cmd>UndotreeToggle<CR>", desc = "Toggle undotree" },

          ["<Leader>a"] = { desc = "AI" },
          ["<Leader>fs"] = { ":w!<cr>", desc = "Save file" },

          ["<Leader>dd"] = { desc = "Delete" },
          ["<Leader>ddd"] = { "dd", desc = "Delete Line" },
          ["<Leader>ddp"] = { "dap", desc = "Delete Paragraph" },
          ["<Leader>ddP"] = { "d}", desc = "Delete Paragraph" },
          ["<Leader>dda"] = { "ggdG", desc = "Delete All" },
          ["<Leader>ddb"] = { 'di"', desc = "Delete Bucket" },

          ["<C-s>"] = { ":w!<cr>", desc = "Save File" },
        },
        v = {
          ["<Leader>a"] = { desc = "AI" },
        },
      },
    },
  },
}
