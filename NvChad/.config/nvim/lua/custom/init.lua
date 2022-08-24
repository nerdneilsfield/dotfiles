-- example file i.e lua/custom/init.lua
-- load your options globals, autocmds here or anything .__.
-- you can even override default options here (core/options.lua)
autocmd({ "BufAdd", "BufEnter" }, {
  callback = function(args)
    require("hop").setup(),
  end,
})
