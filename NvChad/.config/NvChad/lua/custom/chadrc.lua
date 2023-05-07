-- Just an example, supposed to be placed in /lua/custom/
local M = {}

-- make sure you maintain the structure of `core/default_config.lua` here,
-- example of changing theme:

M.ui = {
      theme = "oxocarbon",
}
--
M.plugins = "custom.plugins"
-- chadrc
-- M.mappings = "custom.mappings"
return M
