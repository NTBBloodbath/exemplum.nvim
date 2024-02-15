---@mod exemplum.config exemplum.nvim configuration
---
---@brief [[
---
---exemplum.nvim configuration options
---
---@brief ]]

local config = {}

---@class ExemplumConfig
---@field window_style string The refactor window style, can be: `split` or `float`. Defaults to `"split"`

---exemplum.nvim default configuration
---@type ExemplumConfig
local default_config = {
  window_style = "split",
}

---Set user-defined configurations for exemplum.nvim
---@param user_configs ExemplumConfig User configurations
---@return ExemplumConfig
function config.set(user_configs)
  --[[
  TODO: implement config.check

  local check = require("exemplum.config.check")

  local conf = vim.tbl_deep_extend("force", {
    debug_info = {
      unrecognized_configs = check.get_unrecognized_keys(user_configs, default_config),
    },
  }, default_config, user_configs)

  local ok, err = check.validate(conf)

  if not ok then
    vim.notify(err, vim.log.levels.ERROR)
  end

  if #conf.debug_info.unrecognized_configs > 0 then
    vim.notify("Unrecognized configs found in setup: " .. vim.inspect(config.debug_info.unrecognized_configs), vim.log.levels.WARN)
  end

  return conf
  --]]
end

return config
