---@mod exemplum.config exemplum.nvim configuration
---
---@brief [[
---
---exemplum.nvim configuration options
---
---@brief ]]

local config = {}

---@class ExemplumWindowConfig
---@field style string The refactor window style, can be: `split` (vertical) or `float`. Defaults to `"split"`.
---@field border string The refactor window border, only applies if `window_style` value is `"float"`. Defaults to `"single"`.

---@class ExemplumConfig
---@field window? ExemplumWindowConfig The refactor window style and behaviour.
---@field disable_diagnostics? boolean Whether to disable diagnostics in the refactoring buffer. Defaults to `false`. It is overrided to `true` if the `Exemplum` command was executed with a bang (`!`).

---exemplum.nvim default configuration
---@type ExemplumConfig
config.defaults = {
  window = {
    style = "split",
    border = "single",
  },
  disable_diagnostics = false,
}

return config
