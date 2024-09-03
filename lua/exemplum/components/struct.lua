---@mod exemplum.components.struct

local winbuf = require("exemplum.winbuf")

---Maps filetypes to their corresponding struct node names used by tree-sitter.
---
---This table is used to identify struct nodes in different programming languages.
local struct_node_names = {
  cpp = "struct_specifier",
  lua = "assignment_statement", -- XXX: in Lua, a table counts as a dynamic struct (table_constructor)
  rust = "struct_item",
  python = "class_definition", -- XXX: in Python, Structs are defined as a decorator in a Class node
}

---Gets the assignment_statement chunk content if it has a `table_constructor` node
---@param bufnr number The buffer number
---@param assignment_node TSNode The assignment node
---@return string Class node contents, empty if there was an error
local function get_struct_table_lua(bufnr, assignment_node)
  ---@type string
  local struct_chunk

  -- (assignment_statement
  --   (variable_list <- named_child(0)
  --     name: (identifier))
  --   (expression_list <- named_child(1)
  --     value: (table_constructor))) <- named_child(1):named_child(0)
  if assignment_node:named_child(1):type() == "expression_list" then
    if assignment_node:named_child(1):named_child(0):type() == "table_constructor" then
      -- Grab the whole variable declaration for the struct if there is one, e.g.
      --
      -- local struct_node_names = {}
      --   ^
      -- varaible_declaration node
      if assignment_node:parent():type() ~= "chunk" then
        ---@diagnostic disable-next-line param-type-mismatch
        struct_chunk = vim.treesitter.get_node_text(assignment_node:parent(), bufnr)
      else
        struct_chunk = vim.treesitter.get_node_text(assignment_node, bufnr)
      end
    end
  end

  if not struct_chunk then
    vim.g.exemplum.logger:error("Could not find a table constructor in the current scope")
    return ""
  end

  return struct_chunk
end

---Gets the class chunk content if it has a `@dataclass` decorator
---@param bufnr number The buffer number
---@param class_node TSNode The class node
---@return string Class node contents, empty if there was an error
local function get_struct_class_python(bufnr, class_node)
  ---@type string
  local struct_chunk

  -- (decorated_definition
  --   (decorator
  --     (identifier))
  --   definition: (class_definition
  --     name: (identifier)
  --     body: (block)))
  if class_node:parent():type() ~= "decorated_definition" then
    vim.g.exemplum.logger:error("No '@dataclass' decorator found in this class")
    return ""
  else
    -- unnamed child nodes identifiers:
    -- @dataclass <- 0
    -- class Color(Enum): <- 1
    --     RED = 1        <- 1
    --     GREEN = 2      <- 1
    --     BLUE = 3       <- 1
    ---@diagnostic disable-next-line param-type-mismatch
    if vim.treesitter.get_node_text(class_node:parent():child(0), bufnr) == "@dataclass" then
      ---@diagnostic disable-next-line param-type-mismatch
      struct_chunk = vim.treesitter.get_node_text(class_node:parent(), bufnr)
    end
  end

  return struct_chunk
end

---Retrieves the struct chunk under the cursor in the current buffer.
---
---The extracted struct chunk is stored in the `e` register.
---@param bufnr number The buffer number
---@param filetype string The buffer filetype
---@return table Struct start/end positions. It is empty if there was an error
---@see vim.treesitter.get_node_range
local function get_struct_chunk(bufnr, filetype)
  local struct_node_name = struct_node_names[filetype]

  -- Early return if the filetype is not yet supported
  if not struct_node_name then
    vim.g.exemplum.logger:error("The filetype '" .. filetype .. "' isn't currently supported by exemplum.nvim")
  end

  -- Get the node at the current cursor position
  local current_node = vim.treesitter.get_node()
  ---@type string
  local struct_chunk

  ---@cast current_node -nil
  if current_node:type() == struct_node_name then
    if filetype == "python" then
      struct_chunk = get_struct_class_python(bufnr, current_node)
      if struct_chunk == "" then
        return {}
      end
    elseif filetype == "lua" then
      struct_chunk = get_struct_table_lua(bufnr, current_node)
      if struct_chunk == "" then
        return {}
      end
    else
      struct_chunk = vim.treesitter.get_node_text(current_node, bufnr)
    end
  else
    repeat
      current_node = current_node:parent()
      ---@cast current_node -nil
    until current_node:type() == struct_node_name
    if filetype == "python" then
      ---@cast current_node -nil
      struct_chunk = get_struct_class_python(bufnr, current_node)
      if struct_chunk == "" then
        return {}
      end
    elseif filetype == "lua" then
      ---@cast current_node -nil
      struct_chunk = get_struct_table_lua(bufnr, current_node)
      if struct_chunk == "" then
        return {}
      end
    else
      ---@cast current_node -nil
      struct_chunk = vim.treesitter.get_node_text(current_node, bufnr)
    end
  end
  vim.fn.setreg("e", struct_chunk)

  return { vim.treesitter.get_node_range(current_node) }
end

local function refactor_struct()
  local code_bufnr = vim.api.nvim_win_get_buf(0)
  local buf_filetype = vim.api.nvim_get_option_value("filetype", { buf = code_bufnr })

  -- Get the function node and save the function code into the `e` register
  local struct_range = get_struct_chunk(code_bufnr, buf_filetype)

  -- Early return if there was an error during the chunk retrieval process
  if #struct_range == 0 then
    return
  end

  local refactor_register = vim.fn.getreg("e")

  ---@type number
  local ref_bufnr
  if vim.g.exemplum.window_style == "split" then
    ref_bufnr = winbuf.open_split("exemplum_struct_refactor", buf_filetype)
  elseif vim.g.exemplum.window_style == "float" then
    ref_bufnr = winbuf.open_float("exemplum_struct_refactor", buf_filetype)
  end
  -- Set the refactor buffer contents
  vim.api.nvim_buf_set_lines(ref_bufnr, 0, -1, false, vim.split(vim.fn.getreg("e"), "\n"))

  -- Avoid autocommands duplication
  if #vim.api.nvim_get_autocmds({ group = "Exemplum", pattern = "exemplum_struct_refactor" }) < 1 then
    vim.api.nvim_create_autocmd({ "BufWriteCmd", "BufLeave" }, {
      group = "Exemplum",
      pattern = "exemplum_struct_refactor",
      callback = function(ctx)
        if ctx.event == "BufWriteCmd" then
          -- Get the refactor buffer contents and replace the code in the original buffer if it is different from the original code
          local refactor_code = vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)
          if table.concat(refactor_code, "\n") ~= refactor_register then
            vim.api.nvim_buf_set_text(code_bufnr, struct_range[1], struct_range[2], struct_range[3], struct_range[4], refactor_code)
          end
        end

        -- Disable the modified status while quitting to avoid the save prompts
        vim.api.nvim_set_option_value("modified", false, { buf = ref_bufnr })

        -- Deletes the buffer
        if vim.api.nvim_buf_is_loaded(ctx.buf) then
          vim.cmd.bdelete(ctx.buf)
        end
      end
    })
  end
end

return {
  struct_node_names = struct_node_names,
  refactor = refactor_struct,
  get_struct_table_lua = get_struct_table_lua,
  get_struct_class_python = get_struct_class_python,
}
