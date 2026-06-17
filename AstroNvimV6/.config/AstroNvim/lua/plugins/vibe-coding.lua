local function toggle_ai_terminal(cmd, label)
  return function()
    local executable = vim.split(cmd, "%s+", { trimempty = true })[1]
    if executable and vim.fn.executable(executable) == 0 then
      vim.notify(("%s executable not found: %s"):format(label, executable), vim.log.levels.WARN)
      return
    end

    require("astrocore").toggle_term_cmd(cmd)
  end
end

return {
  {
    "johnseth97/codex.nvim",
    lazy = true,
    cmd = { "Codex", "CodexToggle" },
    keys = {
      {
        "<Leader>ac",
        function() require("codex").toggle() end,
        desc = "Toggle Codex popup",
        mode = { "n", "t" },
      },
      {
        "<Leader>co",
        function() require("codex").toggle() end,
        desc = "Toggle Codex popup",
        mode = { "n", "t" },
      },
    },
    opts = {
      keymaps = {},
      border = "rounded",
      width = 0.9,
      height = 0.9,
      model = nil,
      autoinstall = true,
      panel = false,
      use_buffer = false,
    },
  },
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        n = {
          ["<Leader>a"] = { desc = "AI" },
          ["<Leader>aa"] = { toggle_ai_terminal("aichat", "AiChat"), desc = "Toggle AiChat" },
          ["<Leader>aC"] = { toggle_ai_terminal("codex", "Codex CLI"), desc = "Toggle Codex CLI" },
          ["<Leader>ag"] = { toggle_ai_terminal("gemini", "Gemini CLI"), desc = "Toggle Gemini CLI" },
          ["<Leader>al"] = { toggle_ai_terminal("claude", "Claude Code"), desc = "Toggle Claude Code" },
          ["<Leader>ao"] = { toggle_ai_terminal("opencode", "OpenCode"), desc = "Toggle OpenCode" },
          ["<Leader>aq"] = { toggle_ai_terminal("qwen", "Qwen Code"), desc = "Toggle Qwen Code" },
          ["<Leader>ta"] = { toggle_ai_terminal("aichat", "AiChat"), desc = "Toggle AiChat" },
          ["<Leader>ah"] = { "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle CodeCompanion chat" },
          ["<Leader>ai"] = { "<cmd>CodeCompanion<cr>", desc = "CodeCompanion inline" },
          ["<Leader>ap"] = { "<cmd>CodeCompanionActions<cr>", desc = "CodeCompanion actions" },
        },
        v = {
          ["<Leader>a"] = { desc = "AI" },
          ["<Leader>aa"] = { "<cmd>CodeCompanionChat Add<cr>", desc = "Add selection to CodeCompanion chat" },
          ["<Leader>ah"] = { "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle CodeCompanion chat" },
          ["<Leader>ai"] = { "<cmd>CodeCompanion<cr>", desc = "CodeCompanion inline" },
          ["<Leader>ap"] = { "<cmd>CodeCompanionActions<cr>", desc = "CodeCompanion actions" },
        },
      },
    },
  },
  {
    "saghen/blink.cmp",
    optional = true,
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      opts.sources.default = require("astrocore").list_insert_unique(
        opts.sources.default or { "lsp", "path", "snippets", "buffer" },
        { "copilot" }
      )
    end,
  },
}
