return {
  {
    "greggh/claude-code.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim", -- Required for git operations
    },
    config = function()
      require("claude-code").setup()
    end
  },
  {
    "johnseth97/codex.nvim",
    lazy = true,
    cmd = { 'Codex', 'CodexToggle' }, -- Optional: Load only on command execution
    keys = {
      {
        '<leader>co', -- Change this to your preferred keybinding
        function() require('codex').toggle() end,
        desc = 'Toggle Codex popup',
      },
    },
    opts = {
      keymaps     = {},         -- Disable internal default keymap (<leader>cc -> :CodexToggle)
      border      = 'rounded',  -- Options: 'single', 'double', or 'rounded'
      width       = 0.8,        -- Width of the floating window (0.0 to 1.0)
      height      = 0.8,        -- Height of the floating window (0.0 to 1.0)
      model       = nil,        -- Optional: pass a string to use a specific model (e.g., 'o3-mini')
      autoinstall = true,       -- Automatically install the Codex CLI if not found
    },
    
  },
}

