return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        -- first key is the mode
        n = {
          -- second key is the lefthand side of the map
          -- mappings seen under group name "Buffer"
          -- ["<Leader>b"] = { name = "Buffers" },
          ["<Leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" },
          ["<Leader>bD"] = {
            function()
              require("astroui.status").heirline.buffer_picker(
                function(bufnr) require("astrocore.buffer").close(bufnr) end
              )
            end,
            desc = "Pick to close",
          },
          --force close buffer
          ["<Leader>bQ"] = {
            function() require("astrocore.buffer").close(vim.fn.bufnr(vim.fn.expand "%"), true) end,
            desc = "Force close buffer",
          },

          ["<leader>c"] = { name = "Cursor" },
          ["<leader>z"] = { name = "Zen Mode" },
          ["<leader>j"] = { name = "Jump" },
          ["<leader>js"] = {
            "<cmd> lua require('telescope.builtin').lsp_document_symbols() <CR>",
            desc = "jump to symbols",
          },
          -- tables with the `name` key will be registered with which-key if it's installed
          -- this is useful for naming menus

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

          ["<leader>a"] = { name = "App" },

          ["<leader>fs"] = { ":w!<cr>", desc = "Save file" },

          ["<leader>ta"] = { function() require("astrocore").toggle_term_cmd "aichat" end, desc = "Toggle AiChat" },

          -- quick save
          ["<C-s>"] = { ":w!<cr>", desc = "Save File" }, -- change description but the same command
        },
        v = {
          ["<leader>a"] = { name = "App" },
        },
        t = {
          -- setting a mapping to false will disable it
          -- ["<esc>"] = false,
        },
      },
    },
  },
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      -- mappings = {
      --   n = {
      --     -- this mapping will only be set in buffers with an LSP attached
      --     K = {
      --       function()
      --         vim.lsp.buf.hover()
      --       end,
      --       desc = "Hover symbol details",
      --     },
      --     -- condition for only server with declaration capabilities
      --     gD = {
      --       function()
      --         vim.lsp.buf.declaration()
      --       end,
      --       desc = "Declaration of current symbol",
      --       cond = "textDocument/declaration",
      --     },
      --   },
      -- },
    },
  },
}
