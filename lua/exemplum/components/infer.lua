---@mod exemplum.components.infer

local winbuf = require("exemplum.winbuf")
local enum = require("exemplum.components.enum")
local struct = require("exemplum.components.struct")
local function_nodes = require("exemplum.components.function").function_node_names
local variable_nodes = require("exemplum.components.variable").variable_node_names

---Retrieves the nearest code chunk under the cursor in the current buffer.
---
---The extracted code chunk is stored in the `e` register.
---@param bufnr number The buffer number
---@param filetype string The buffer filetype
---@return table Variable start/end positions. It is empty if there was a problem.
---@see vim.treesitter.get_node_range
local function get_node_chunk(bufnr, filetype)
  local enum_node_name = enum.enum_node_names[filetype]
  local struct_node_name = struct.struct_node_names[filetype]
  local function_node_name = function_nodes[filetype]
  local variable_node_name = variable_nodes[filetype]

  -- Early return if the filetype is not yet supported
  if not function_node_name then
    vim.g.exemplum.logger:error("The filetype '" .. filetype .. "' isn't currently supported by exemplum.nvim")
    return {}
  end

  -- Get the node at the current cursor position
  local current_node = vim.treesitter.get_node()
  ---@type string
  local node_chunk

  ---@cast current_node -nil
  while true do
    -- If there's no parent for the current node then break
    -- because we hit the file root node
    if not current_node then
      break
    end

    -- Precedence order (in theory?):
    -- - variable
    -- - function
    -- - struct
    -- - enum
    ---@cast current_node -nil
    if current_node:type() == variable_node_name or current_node:type() == function_node_name then
      node_chunk = vim.treesitter.get_node_text(current_node, bufnr)
      break
    else
      if filetype == "python" and current_node:type() == struct_node_name then
          node_chunk = struct.get_struct_class_python(bufnr, current_node)
          break
      elseif filetype == "python" and current_node:type() == enum_node_name then
          node_chunk = enum.get_enum_inheritance_python(bufnr, current_node)
          break
      --- XXX: Lua does not support enums
      elseif filetype == "lua" and current_node:type() == struct_node_name then
        node_chunk = struct.get_struct_table_lua(bufnr, current_node)
        break
      else
        if current_node:type() == struct_node_name or current_node:type() == enum_node_name then
          node_chunk = vim.treesitter.get_node_text(current_node, bufnr)
          break
        end
      end
    end

    current_node = current_node:parent()
  end

  if not node_chunk then
    vim.g.exemplum.logger:error("Failed to find a code chunk to refactor: probably your cursor is placed in the wrong scope?")
    return {}
  end

  vim.fn.setreg("e", node_chunk)
  ---@cast current_node -nil
  return { vim.treesitter.get_node_range(current_node) }
end

local function try_refactor()
  local code_bufnr = vim.api.nvim_win_get_buf(0)
  local buf_filetype = vim.api.nvim_get_option_value("filetype", { buf = code_bufnr })

  local node_range = get_node_chunk(code_bufnr, buf_filetype)
  local refactor_register = vim.fn.getreg("e")

  -- Early return if there was an error during the chunk retrieval process
  if #node_range == 0 then
    return {}
  end

  ---@type number
  local ref_bufnr
  if vim.g.exemplum.window_style == "split" then
    ref_bufnr = winbuf.open_split("exemplum_infer_refactor", buf_filetype)
  elseif vim.g.exemplum.window_style == "float" then
    ref_bufnr = winbuf.open_float("exemplum_infer_refactor", buf_filetype)
  end

  -- Set the refactor buffer contents
  vim.api.nvim_buf_set_lines(ref_bufnr, 0, -1, false, vim.split(vim.fn.getreg("e"), "\n"))

  -- Avoid autocommands duplication
  if #vim.api.nvim_get_autocmds({ group = "Exemplum", pattern = "exemplum_infer_refactor" }) < 1 then
    vim.api.nvim_create_autocmd({ "BufWriteCmd", "BufLeave" }, {
      group = "Exemplum",
      pattern = "exemplum_infer_refactor",
      callback = function(ctx)
        if ctx.event == "BufWriteCmd" then
          -- Get the refactor buffer contents and replace the code in the original buffer if it is different from the original code
          local refactor_code = vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)
          if table.concat(refactor_code, "\n") ~= refactor_register then
            vim.api.nvim_buf_set_text(code_bufnr, node_range[1], node_range[2], node_range[3], node_range[4], refactor_code)
          end
        end

        -- Disable the modified status while quitting to avoid the save prompts
        vim.api.nvim_set_option_value("modified", false, { buf = ctx.buf })

        -- Deletes the buffer
        if vim.api.nvim_buf_is_loaded(ctx.buf) then
          vim.cmd.bdelete(ctx.buf)
        end
      end
    })
  end
end

return { try_refactor = try_refactor }
