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
---@field window_border string The refactor window border, only applies if `window_style` value is `"float"`. Defaults to `"single"`.

---exemplum.nvim default configuration
---@type ExemplumConfig
config.defaults = {
  window_style = "split",
  window_border = "single",
}

return config
