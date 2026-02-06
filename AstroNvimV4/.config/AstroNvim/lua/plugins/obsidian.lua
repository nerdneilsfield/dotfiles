-- 判断一个文件夹是否存在
local function is_dir_exists(path)
  local ok, err, code = os.rename(path, path)
  if not ok then
    if code == 13 then
      -- Permission denied, but it exists
      return true
    end
    return false
  end
  return true
end

if not is_dir_exists(vim.env.HOME .. "/obsidian-vault") then return {} end

-- 定义一个函数来读取用户输入并执行命令
local function execute_obsidian_tags()
  -- 使用 input() 函数读取用户输入
  local user_input = vim.fn.input "Enter tags: "
  -- 构建并执行命令
  local command = string.format(":ObsidianTags %s", user_input)
  vim.cmd(command)
end

local function new_obsidian_notes()
  -- 使用 input() 函数读取用户输入
  local user_input = vim.fn.input "Enter Notes Name: "
  -- 构建并执行命令
  local command = string.format(":ObsidianNew %s", user_input)
  vim.cmd(command)
end

return {
  "epwalsh/obsidian.nvim",
  -- the obsidian vault in this default config  ~/obsidian-vault
  -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand':
  -- event = { "bufreadpre " .. vim.fn.expand "~" .. "/my-vault/**.md" },
  -- event = { "BufReadPre  */obsidian-vault/*.md" },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
    "nvim-telescope/telescope.nvim",
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["<leader>ao"] = { name = "Obsidian" },
            ["<leader>aon"] = { new_obsidian_notes, desc = "new obsidian notes" },
            ["<leader>aot"] = { "<cmd>ObsidianToday<CR>", desc = "open obsidian today" },
            ["<leader>aoT"] = { execute_obsidian_tags, desc = "list tags" },
            ["<leader>aoi"] = { "<cmd>ObsidianTemplate<CR>", desc = "insert template" },
            ["<leader>aoo"] = { "<cmd>ObsidianOpen<CR>", desc = "open obsidian" },
            ["<leader>aoy"] = { "<cmd>ObsidianYesterday<CR>", desc = "open obsidian yesterday" },
            ["<leader>aob"] = { "<cmd>ObsidianBacklinks<CR>", desc = "open obsidian backlinks" },
            ["<leader>aoL"] = { "<cmd>ObsidianLinks<CR>", desc = "open obsidian all links" },
            ["<leader>aos"] = { "<cmd>ObsidianSearch<CR>", desc = "open obsidian search" },
            ["gf"] = {
              function()
                if require("obsidian").util.cursor_on_markdown_link() then
                  return "<Cmd>ObsidianFollowLink<CR>"
                else
                  return "gf"
                end
              end,
              desc = "Obsidian Follow Link",
            },
          },
        },
        v = {
          ["<leader>ao"] = { name = "Obsidian" },
          ["<leader>aoe"] = { "<cmd>ObsidianExtractNote", desc = "extract text in new notes and link to it" },
        },
      },
    },
  },
  opts = {
    dir = vim.env.HOME .. "/obsidian-vault", -- specify the vault location. no need to call 'vim.fn.expand' here
    use_advanced_uri = true,
    finder = "telescope.nvim",

    templates = {
      subdir = "Templates",
      date_format = "%Y-%m-%d-%a",
      time_format = "%H:%M",
    },

    new_notes_subdir = "Fleeting Notes",
    notes_subdir = "Fleeting Notes",

    daily_notes = {
      -- Optional, if you keep daily notes in a separate directory.
      folder = "Daily",
      -- Optional, if you want to change the date format for the ID of daily notes.
      date_format = "%Y-%m-%d_dddd",
      -- Optional, if you want to change the date format of the default alias of daily notes.
      alias_format = "%B %-d, %Y",
      -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
      template = "DailyNoteTemplate.md",
    },

    note_frontmatter_func = function(note)
      -- This is equivalent to the default frontmatter function.
      local out = { id = note.id, aliases = note.aliases, tags = note.tags }
      -- `note.metadata` contains any manually added fields in the frontmatter.
      -- So here we just make sure those fields are kept in the frontmatter.
      if note.metadata ~= nil and require("obsidian").util.table_length(note.metadata) > 0 then
        for k, v in pairs(note.metadata) do
          out[k] = v
        end
      end
      return out
    end,

    -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
    -- URL it will be ignored but you can customize this behavior here.
    follow_url_func = vim.ui.open or function(url) require("astrocore").system_open(url) end,
  },
}
