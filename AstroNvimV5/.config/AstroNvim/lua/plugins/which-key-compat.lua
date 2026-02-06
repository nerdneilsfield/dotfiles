---@type LazySpec
return {
  {
    "folke/which-key.nvim",
    lazy = false,
    opts = function(_, opts)
      local ok, wk = pcall(require, "which-key")
      if ok and wk and wk.add == nil and wk.register ~= nil then
        wk.add = function(mappings, wk_opts) return wk.register(mappings, wk_opts) end
      end
      return opts
    end,
  },
}
