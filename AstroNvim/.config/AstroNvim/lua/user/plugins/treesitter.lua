return {
  "nvim-treesitter/nvim-treesitter",

  opts = {

    
    -- add more things to the ensure_installed table protecting against community packs modifying it
    ensure_installed =  {
      "lua",
      "rust",
      "verilog",
      "java",
      "cpp",
      "c",
      "zig",
      "python",
      "ruby",
      "go",
      "c_sharp",
      "javascript",
      "typescript",
      "css",
      "html",
      "json",
      "toml",
      "yaml",
      "cmake",
      "cuda",
      "latex",
      "bibtex",
      "scala",
      "vim",
      "vue",
      "bash",
    },
  },
}