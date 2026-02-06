return {
  {
    "johnseth97/codex.nvim",
    lazy = true,
    cmd = { "Codex", "CodexToggle" },
    keys = {
      {
        "<Leader>co",
        function() require("codex").toggle() end,
        desc = "Toggle Codex popup",
      },
    },
    opts = {
      keymaps = {},
      border = "rounded",
      width = 0.8,
      height = 0.8,
      model = nil,
      autoinstall = true,
    },
  },
}
