-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  -- colorscheme
  { import = "astrocommunity.colorscheme.catppuccin" },
  { import = "astrocommunity.colorscheme.tokyonight-nvim" },
  -- lsp
  { import = "astrocommunity.lsp.actions-preview-nvim" },
  { import = "astrocommunity.lsp.lspsaga-nvim" },
  { import = "astrocommunity.lsp.lsplinks-nvim" },
  -- remote-development
  { import = "astrocommunity.remote-development.netman-nvim" },
  -- note-taking
  { import = "astrocommunity.note-taking.obsidian-nvim" },
  -- snippet
  -- { import = "astrocommunity.snippet.nvim-snippets" },
  -- completion
  { import = "astrocommunity.completion.copilot-lua-cmp" },
  { import = "astrocommunity.completion.tabnine-nvim" },
  { import = "astrocommunity.completion.cmp-cmdline" },
  -- markdown and latex
  { import = "astrocommunity.markdown-and-latex.vimtex" },
  { import = "astrocommunity.markdown-and-latex.glow-nvim" },
  -- pack
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.cpp" },
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.pack.go" },
  { import = "astrocommunity.pack.bash" },
  { import = "astrocommunity.pack.zig" },
  { import = "astrocommunity.pack.proto" },
  { import = "astrocommunity.pack.html-css" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.yaml" },
  { import = "astrocommunity.pack.python" },
  { import = "astrocommunity.pack.markdown" },
  { import = "astrocommunity.pack.typst" },
  -- import/override with your plugins folder
}
