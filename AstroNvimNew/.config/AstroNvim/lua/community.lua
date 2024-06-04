-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  --bars-and-lines
  { import = "astrocommunity.bars-and-lines.dropbar-nvim" },
  -- colorscheme
  { import = "astrocommunity.colorscheme.catppuccin" },
  { import = "astrocommunity.colorscheme.tokyonight-nvim" },
  -- code-runner
  { import = "astrocommunity.code-runner.toggletasks-nvim" },
  -- lsp
  { import = "astrocommunity.lsp.actions-preview-nvim" },
  { import = "astrocommunity.lsp.lspsaga-nvim" },
  { import = "astrocommunity.lsp.lsplinks-nvim" },
  -- editor
  { import = "astrocommunity.editing-support.multiple-cursors-nvim" },
  { import = "astrocommunity.editing-support.comment-box-nvim" },
  { import = "astrocommunity.editing-support.true-zen-nvim" },
  { import = "astrocommunity.editing-support.undotree" },
  { import = "astrocommunity.editing-support.telescope-undo-nvim" },
  -- terminal-intergration
  { import = "astrocommunity.terminal-integration.toggleterm-manager-nvim" },
  -- indent
  { import = "astrocommunity.indent.indent-blankline-nvim" },
  { import = "astrocommunity.indent.indent-rainbowline" },
  -- remote-development
  { import = "astrocommunity.remote-development.netman-nvim" },
  -- note-taking
  -- { import = "astrocommunity.note-taking.obsidian-nvim" },
  -- snippet
  -- { import = "astrocommunity.snippet.nvim-snippets" },
  -- media
  -- { import = "astrocommunity.media.image-nvim" },
  -- workflow
  -- { import = "astrocommunity.workflow.hardtime-nvim" },
  -- recipte
  { import = "astrocommunity.recipes.neovide" },
  -- completion
  { import = "astrocommunity.completion.copilot-lua-cmp" },
  { import = "astrocommunity.completion.tabnine-nvim" },
  { import = "astrocommunity.completion.cmp-cmdline" },
  -- markdown and latex
  { import = "astrocommunity.markdown-and-latex.vimtex" },
  { import = "astrocommunity.markdown-and-latex.glow-nvim" },
  -- pack
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.docker" },
  { import = "astrocommunity.pack.cpp" },
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.pack.go" },
  -- { import = "astrocommunity.pack.bash" },
  { import = "astrocommunity.pack.zig" },
  { import = "astrocommunity.pack.proto" },
  { import = "astrocommunity.pack.html-css" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.yaml" },
  { import = "astrocommunity.pack.toml" },
  { import = "astrocommunity.pack.python" },
  { import = "astrocommunity.pack.markdown" },
  { import = "astrocommunity.pack.typst" },
  { import = "astrocommunity.pack.verilog" },
  { import = "astrocommunity.pack.ps1" },
  -- import/override with your plugins folder
}
