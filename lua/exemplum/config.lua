---@mod exemplum.config exemplum.nvim configuration
---
---@brief [[
---
---exemplum.nvim configuration options
---
---@brief ]]

local config = {}

---@class ExemplumConfig
---@field window_style string The refactor window style, can be: `split` (vertical) or `float`. Defaults to `"split"`.

---exemplum.nvim default configuration
---@type ExemplumConfig
config.defaults = {
  window_style = "split",
}

return config
