  -- refrence: Jie-dong Hao's configuration
  
  -- check if we have the latest stable version of nvim
  local expected_ver = "0.7.2"

  local utils = require "utils"
  local nvim_ver = utils.get_nvim_version()
  
  if nvim_ver ~= expected_ver then
    local msg = string.format("Unsupported nvim version: expect %s, but got %s instead!", expected_ver, nvim_ver)
    vim.api.nvim_echo({ { msg, "ErrorMsg" } }, false, {})
    return
  end
  
  local vim_conf_files = {
    "init-basic.vim",
    "init-config.vim",
    "init-tabsize.vim",
    "init-plugins.vim",
    -- "init-style.vim",
  }
  
  -- source all the vim config files
  for _, name in ipairs(vim_conf_files) do
    print(name)
    local path = string.format("%s/vim/%s", vim.fn.stdpath('config'), name)
    local source_cmd = "source " .. path
    vim.cmd(source_cmd)
  end
  