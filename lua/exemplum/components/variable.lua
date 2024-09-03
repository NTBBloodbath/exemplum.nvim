---@mod exemplum.components.variables

local winbuf = require("exemplum.winbuf")

--- Maps filetypes to their corresponding variable node names used by tree-sitter.
---
--- This table is used to identify variable nodes in different programming languages.
local variable_node_names = {
  cpp = "declaration",
  lua = "variable_declaration",
  rust = "let_declaration",
  python = "assignment",
}

---Retrieves the variable chunk under the cursor in the current buffer.
---
---The extracted variable chunk is stored in the `e` register.
---@param bufnr number The buffer number
---@param filetype string The buffer filetype
---@return table Variable start/end positions
---@see vim.treesitter.get_node_range
local function get_variable_chunk(bufnr, filetype)
  local variable_node_name = variable_node_names[filetype]

  -- Early return if the filetype is not yet supported
  if not variable_node_name then
    vim.g.exemplum.logger:error("The filetype '" .. filetype .. "' isn't currently supported by exemplum.nvim")
    return {}
  end

  -- Get the node at the current cursor position
  local current_node = vim.treesitter.get_node()
  ---@type string
  local variable_chunk

  ---@cast current_node -nil
  if current_node:type() == variable_node_name then
    variable_chunk = vim.treesitter.get_node_text(current_node, bufnr)
  else
    repeat
      if current_node ~= nil then
        current_node = current_node:parent()
      else
        break
      end
      ---@cast current_node -nil
    until current_node ~= nil and current_node:type() == variable_node_name

    -- Early return if a variable node could not be found
    if not current_node then
      vim.g.exemplum.logger:error("Could not find a variable in the current scope: probably your cursor is placed in the wrong scope?")
      return {}
    end

    ---@cast current_node -nil
    variable_chunk = vim.treesitter.get_node_text(current_node, bufnr)
  end
  vim.fn.setreg("e", variable_chunk)

  return { vim.treesitter.get_node_range(current_node) }
end

local function refactor_variable()
  local code_bufnr = vim.api.nvim_win_get_buf(0)
  local buf_filetype = vim.api.nvim_get_option_value("filetype", { buf = code_bufnr })

  -- Get the variable node and save the variable code into the `e` register
  local variable_range = get_variable_chunk(code_bufnr, buf_filetype)

  if #variable_range == 0 then
    return {}
  end

  local refactor_register = vim.fn.getreg("e")

  ---@type number
  local ref_bufnr
  if vim.g.exemplum.window_style == "split" then
    ref_bufnr = winbuf.open_split("exemplum_variable_refactor", buf_filetype)
  elseif vim.g.exemplum.window_style == "float" then
    ref_bufnr = winbuf.open_float("exemplum_variable_refactor", buf_filetype)
  end

  -- Set the refactor buffer contents
  vim.api.nvim_buf_set_lines(ref_bufnr, 0, -1, false, vim.split(vim.fn.getreg("e"), "\n"))

  -- Avoid autocommands duplication
  if #vim.api.nvim_get_autocmds({ group = "Exemplum", pattern = "exemplum_variable_refactor" }) < 1 then
    vim.api.nvim_create_autocmd({ "BufWriteCmd", "BufLeave" }, {
      group = "Exemplum",
      pattern = "exemplum_variable_refactor",
      callback = function(ctx)
        if ctx.event == "BufWriteCmd" then
          -- Get the refactor buffer contents and replace the code in the original buffer if it is different from the original code
          local refactor_code = vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)
          if table.concat(refactor_code, "\n") ~= refactor_register then
            vim.api.nvim_buf_set_text(code_bufnr, variable_range[1], variable_range[2], variable_range[3], variable_range[4], refactor_code)
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

return {
  variable_node_names = variable_node_names,
  refactor = refactor_variable,
}
