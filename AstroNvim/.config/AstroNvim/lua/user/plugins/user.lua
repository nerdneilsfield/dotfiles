return {
  -- You can also add new plugins here as well:
  -- Add plugins, the lazy syntax
  -- "andweeb/presence.nvim",
  -- {
  --   "ray-x/lsp_signature.nvim",
  --   event = "BufRead",
  --   config = function()
  --     require("lsp_signature").setup()
  --   end,
  -- },


      ------ movement ------
  ----------------------

    {
        "jinh0/eyeliner.nvim",
        -- enabled = false,
        lazy = false,
        opts = {
        highlight_on_key = true,
        dim = true,
        },
    },

    {
        "TheSafdarAwan/find-extender.nvim",
        enabled = false,
        keys = { "f", "F", "F", "T", "t", "t", "T" },
        config = true,
    },



}