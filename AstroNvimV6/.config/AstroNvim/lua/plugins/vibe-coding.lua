-- AI 功能默认关闭，用 <Leader>at 或 :AIToggle 在本次会话中打开。
vim.g.ai_enabled = false

local AI_CORE_PLUGINS = { "copilot.lua", "blink-copilot" }

local function ai_is_on()
  return vim.g.ai_enabled == true
end

local function notify_ai_off()
  vim.notify("AI 功能已关闭，先按 <Leader>at 打开（仅本次会话）", vim.log.levels.WARN)
end

local function ensure_ai()
  if ai_is_on() then return true end
  notify_ai_off()
  return false
end

local function with_ai(fn)
  return function(...)
    if not ensure_ai() then return end
    return fn(...)
  end
end

local function enable_ai()
  if ai_is_on() then
    vim.notify("AI 功能已经是打开的", vim.log.levels.INFO)
    return
  end
  vim.g.ai_enabled = true
  local ok_lazy, lazy = pcall(require, "lazy")
  if ok_lazy then lazy.load { plugins = AI_CORE_PLUGINS, wait = true } end
  pcall(vim.cmd, "Copilot enable")
  vim.notify("AI 功能已打开（仅本次会话）", vim.log.levels.INFO)
end

local function disable_ai()
  if not ai_is_on() then
    vim.notify("AI 功能已经是关闭的", vim.log.levels.INFO)
    return
  end
  vim.g.ai_enabled = false
  pcall(vim.cmd, "Copilot disable")
  vim.notify("AI 功能已关闭", vim.log.levels.INFO)
end

local function toggle_ai()
  if ai_is_on() then
    disable_ai()
  else
    enable_ai()
  end
end

local function toggle_ai_terminal(cmd, label)
  return with_ai(function()
    local executable = vim.split(cmd, "%s+", { trimempty = true })[1]
    if executable and vim.fn.executable(executable) == 0 then
      vim.notify(("%s executable not found: %s"):format(label, executable), vim.log.levels.WARN)
      return
    end
    require("astrocore").toggle_term_cmd(cmd)
  end)
end

return {
  {
    "zbirenbaum/copilot.lua",
    lazy = true,
    cmd = "Copilot",
    opts = {
      panel = { enabled = false },
      suggestion = { enabled = false },
    },
  },
  {
    "fang2hou/blink-copilot",
    lazy = true,
    dependencies = { "zbirenbaum/copilot.lua" },
  },
  {
    "saghen/blink.cmp",
    optional = true,
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.copilot = {
        name = "copilot",
        module = "blink-copilot",
        score_offset = 100,
        async = true,
        enabled = function() return vim.g.ai_enabled == true end,
      }
      opts.sources.default = require("astrocore").list_insert_unique(
        opts.sources.default or { "lsp", "path", "snippets", "buffer" },
        { "lsp", "path", "snippets", "buffer", "copilot" }
      )
    end,
  },
  {
    "olimorris/codecompanion.nvim",
    lazy = true,
    cmd = {
      "CodeCompanion",
      "CodeCompanionActions",
      "CodeCompanionChat",
      "CodeCompanionCmd",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {},
  },
  {
    "johnseth97/codex.nvim",
    lazy = true,
    cmd = { "Codex", "CodexToggle" },
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
    "coder/claudecode.nvim",
    lazy = true,
    dependencies = {
      { "folke/snacks.nvim", opts = { terminal = { enabled = true } } },
    },
    cmd = {
      "ClaudeCode",
      "ClaudeCodeFocus",
      "ClaudeCodeSelectModel",
      "ClaudeCodeAdd",
      "ClaudeCodeSend",
      "ClaudeCodeTreeAdd",
      "ClaudeCodeStatus",
      "ClaudeCodeStart",
      "ClaudeCodeStop",
      "ClaudeCodeOpen",
      "ClaudeCodeClose",
      "ClaudeCodeDiffAccept",
      "ClaudeCodeDiffDeny",
      "ClaudeCodeCloseAllDiffs",
    },
    opts = {},
  },
  {
    "NickvanDyke/opencode.nvim",
    lazy = true,
    dependencies = {
      {
        "folke/snacks.nvim",
        opts = { input = { enabled = true }, picker = { enabled = true }, terminal = { enabled = true } },
      },
    },
  },
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      commands = {
        AIToggle = { toggle_ai, desc = "Toggle AI features (this session)" },
        AIEnable = { enable_ai, desc = "Enable AI features (this session)" },
        AIDisable = { disable_ai, desc = "Disable AI features" },
      },
      mappings = {
        n = {
          ["<Leader>a"] = { desc = "AI" },
          ["<Leader>at"] = { toggle_ai, desc = "Toggle AI (this session)" },
          ["<Leader>aa"] = { toggle_ai_terminal("aichat", "AiChat"), desc = "Toggle AiChat" },
          ["<Leader>aC"] = { toggle_ai_terminal("codex", "Codex CLI"), desc = "Toggle Codex CLI" },
          ["<Leader>ag"] = { toggle_ai_terminal("gemini", "Gemini CLI"), desc = "Toggle Gemini CLI" },
          ["<Leader>aq"] = { toggle_ai_terminal("qwen", "Qwen Code"), desc = "Toggle Qwen Code" },
          ["<Leader>ta"] = { toggle_ai_terminal("aichat", "AiChat"), desc = "Toggle AiChat" },
          ["<Leader>ah"] = {
            with_ai(function() vim.cmd "CodeCompanionChat Toggle" end),
            desc = "Toggle CodeCompanion chat",
          },
          ["<Leader>ai"] = { with_ai(function() vim.cmd "CodeCompanion" end), desc = "CodeCompanion inline" },
          ["<Leader>ap"] = { with_ai(function() vim.cmd "CodeCompanionActions" end), desc = "CodeCompanion actions" },
          ["<Leader>al"] = { with_ai(function() vim.cmd "ClaudeCode" end), desc = "Toggle Claude Code" },
          ["<Leader>am"] = { with_ai(function() vim.cmd "ClaudeCodeSelectModel" end), desc = "Select Claude model" },
          ["<Leader>ab"] = { with_ai(function() vim.cmd "ClaudeCodeAdd %" end), desc = "Add buffer to Claude" },
          ["<Leader>ay"] = { with_ai(function() vim.cmd "ClaudeCodeDiffAccept" end), desc = "Accept Claude diff" },
          ["<Leader>an"] = { with_ai(function() vim.cmd "ClaudeCodeDiffDeny" end), desc = "Deny Claude diff" },
          ["<Leader>ao"] = {
            with_ai(function()
              require("lazy").load { plugins = { "opencode.nvim" } }
              require("opencode").toggle()
            end),
            desc = "Toggle OpenCode",
          },
          ["<Leader>ae"] = {
            with_ai(function()
              require("lazy").load { plugins = { "opencode.nvim" } }
              require("opencode").prompt("Explain @this and its context", { submit = true })
            end),
            desc = "OpenCode explain",
          },
          ["<Leader>ak"] = {
            with_ai(function()
              require("lazy").load { plugins = { "opencode.nvim" } }
              require("opencode").ask("@this: ", { submit = true })
            end),
            desc = "Ask OpenCode about this",
          },
          ["<Leader>ac"] = {
            with_ai(function() require("codex").toggle() end),
            desc = "Toggle Codex popup",
          },
          ["<Leader>co"] = {
            with_ai(function() require("codex").toggle() end),
            desc = "Toggle Codex popup",
          },
        },
        v = {
          ["<Leader>a"] = { desc = "AI" },
          ["<Leader>at"] = { toggle_ai, desc = "Toggle AI (this session)" },
          ["<Leader>aa"] = {
            with_ai(function() vim.cmd "CodeCompanionChat Add" end),
            desc = "Add selection to CodeCompanion chat",
          },
          ["<Leader>ah"] = {
            with_ai(function() vim.cmd "CodeCompanionChat Toggle" end),
            desc = "Toggle CodeCompanion chat",
          },
          ["<Leader>ai"] = { with_ai(function() vim.cmd "CodeCompanion" end), desc = "CodeCompanion inline" },
          ["<Leader>ap"] = { with_ai(function() vim.cmd "CodeCompanionActions" end), desc = "CodeCompanion actions" },
          ["<Leader>as"] = { with_ai(function() vim.cmd "ClaudeCodeSend" end), desc = "Send selection to Claude" },
          ["<Leader>ae"] = {
            with_ai(function()
              require("lazy").load { plugins = { "opencode.nvim" } }
              require("opencode").prompt("Explain @this and its context", { submit = true })
            end),
            desc = "OpenCode explain",
          },
          ["<Leader>ak"] = {
            with_ai(function()
              require("lazy").load { plugins = { "opencode.nvim" } }
              require("opencode").ask("@this: ", { submit = true })
            end),
            desc = "Ask OpenCode about this",
          },
        },
        t = {
          ["<Leader>ac"] = {
            with_ai(function() require("codex").toggle() end),
            desc = "Toggle Codex popup",
          },
          ["<Leader>co"] = {
            with_ai(function() require("codex").toggle() end),
            desc = "Toggle Codex popup",
          },
        },
      },
    },
  },
}
