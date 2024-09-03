---@toc exemplum.contents

---@mod exemplum.intro Introduction
---@brief [[
---Take your functions and easily refactor them
---while keeping an eye on the initial implementation
---@brief ]]
---
---@mod exemplum
---@brief [[
---
---Commands:
---
---The ':Exemplum' command accepts the following arguments:
--- 'code_type' - The type of code chunk to refactor.
---               Currently it can be either `enum`, `struct`,
---               `function` or `variable`.
---
---The ':Exemplum' command also accepts a bang modifier (`!`).
---At the moment if you add the bang modifier, exemplum will
---disable the diagnostics in the refactoring buffer.
---
---@brief ]]

local exemplum = {}
return exemplum
