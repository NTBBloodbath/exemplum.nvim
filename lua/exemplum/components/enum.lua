---@mod exemplum.components.enum

local winbuf = require("exemplum.winbuf")

---Maps filetypes to their corresponding enum node names used by tree-sitter.
---
---This table is used to identify enum nodes in different programming languages.
local enum_node_names = {
  cpp = "enum_specifier",
  rust = "enum_item",
  python = "class_definition", -- XXX: in Python, Enum is another Class that is inherited
}

---Gets the class chunk content if it has an inheritance from the Enum class
---@param bufnr number The buffer number
---@param class_node TSNode The class node
---@return string Class node contents, empty if there was an error
local function get_enum_inheritance_python(bufnr, class_node)
  ---@type string
  local enum_chunk

  -- (class_definition
  --   name: (identifier) <- First named child (0)
  --   superclasses: (argument_list <- Second named child (1) if there is an inheritance
  --     (identifier))
  --   body: (block)) <- Second named child (1) if there is no inheritance, otherwise it is the third one (2)
  if class_node:named_child(1):type() ~= "argument_list" then
    vim.g.exemplum.logger:error("Could not find an inheritance in the class")
    return ""
  else
    -- unnamed child nodes identifiers:
    -- class Color(Enum):
    --            ^ ^^ ^
    --            | || |
    --            1 02 3
    ---@diagnostic disable-next-line param-type-mismatch
    if vim.treesitter.get_node_text(class_node:named_child(1):child(1), bufnr) == "Enum" then
      enum_chunk = vim.treesitter.get_node_text(class_node, bufnr)
    end
  end

  return enum_chunk
end

---Retrieves the enum chunk under the cursor in the current buffer.
---
---The extracted enum chunk is stored in the `e` register.
---@param bufnr number The buffer number
---@param filetype string The buffer filetype
---@return table Enum start/end positions. It is empty if there was an error
---@see vim.treesitter.get_node_range
local function get_enum_chunk(bufnr, filetype)
  local enum_node_name = enum_node_names[filetype]

  -- Early return if ran in Lua, because Lua does not have enums
  if filetype == "lua" then
    vim.g.exemplum.logger:error("Lua does not support Enums")
    return {}
  end

  -- Early return if the filetype is not yet supported
  if not enum_node_name then
    vim.g.exemplum.logger:error("The filetype '" .. filetype .. "' isn't currently supported by exemplum.nvim")
    return {}
  end

  -- Get the node at the current cursor position
  local current_node = vim.treesitter.get_node()
  ---@type string
  local enum_chunk

  ---@cast current_node -nil
  if current_node:type() == enum_node_name then
    if filetype == "python" then
      enum_chunk = get_enum_inheritance_python(bufnr, current_node)
      if enum_chunk == "" then
        vim.g.exemplum.logger:error("No Enum inherited class was found")
        return {}
      end
    else
      enum_chunk = vim.treesitter.get_node_text(current_node, bufnr)
    end
  else
    repeat
      if current_node ~= nil then
        current_node = current_node:parent()
      else
        break
      end
      ---@cast current_node -nil
    until current_node ~= nil and current_node:type() == enum_node_name

    -- Early return if an enum node could not be found
    if not current_node then
      vim.g.exemplum.logger:error("Could not find an enum in the current scope: probably your cursor is placed in the wrong scope?")
      return {}
    end

    if filetype == "python" then
      ---@cast current_node -nil
      enum_chunk = get_enum_inheritance_python(bufnr, current_node)
      if enum_chunk == "" then
        vim.g.exemplum.logger:error("No Enum inherited class was found")
        return {}
      end
    else
      ---@cast current_node -nil
      enum_chunk = vim.treesitter.get_node_text(current_node, bufnr)
    end
  end
  vim.fn.setreg("e", enum_chunk)

  return { vim.treesitter.get_node_range(current_node) }
end

local function refactor_enum()
  local code_bufnr = vim.api.nvim_win_get_buf(0)
  local buf_filetype = vim.api.nvim_get_option_value("filetype", { buf = code_bufnr })

  -- Get the enum node and save the enum code into the `e` register
  local enum_range = get_enum_chunk(code_bufnr, buf_filetype)

  -- Early return if there was an error during the chunk retrieval process
  if #enum_range == 0 then
    return {}
  end

  local refactor_register = vim.fn.getreg("e")

  ---@type number
  local ref_bufnr
  if vim.g.exemplum.window_style == "split" then
    ref_bufnr = winbuf.open_split("exemplum_enum_refactor", buf_filetype)
  elseif vim.g.exemplum.window_style == "float" then
    ref_bufnr = winbuf.open_float("exemplum_enum_refactor", buf_filetype)
  end
  -- Set the refactor buffer contents
  vim.api.nvim_buf_set_lines(ref_bufnr, 0, -1, false, vim.split(vim.fn.getreg("e"), "\n"))

  -- Avoid autocommands duplication
  if #vim.api.nvim_get_autocmds({ group = "Exemplum", pattern = "exemplum_enum_refactor" }) < 1 then
    vim.api.nvim_create_autocmd({ "BufWriteCmd", "BufLeave" }, {
      group = "Exemplum",
      pattern = "exemplum_enum_refactor",
      callback = function(ctx)
        if ctx.event == "BufWriteCmd" then
          -- Get the refactor buffer contents and replace the code in the original buffer if it is different from the original code
          local refactor_code = vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)
          if table.concat(refactor_code, "\n") ~= refactor_register then
            vim.api.nvim_buf_set_text(code_bufnr, enum_range[1], enum_range[2], enum_range[3], enum_range[4], refactor_code)
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

  return enum_range
end

return {
  enum_node_names = enum_node_names,
  refactor = refactor_enum,
  get_enum_inheritance_python = get_enum_inheritance_python,
}
