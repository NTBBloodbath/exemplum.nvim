---@mod exemplum.components.functions

local winbuf = require("exemplum.winbuf")

--- Maps filetypes to their corresponding function node names used by tree-sitter.
---
--- This table is used to identify function nodes in different programming languages.
local function_node_names = {
  c = "function_definition",
  cpp = "function_definition",
  go = "function_declaration",
  lua = "function_declaration",
  rust = "function_item",
  python = "function_definition",
}

---Retrieves the function chunk under the cursor in the current buffer.
---
---The extracted function chunk is stored in the `e` register.
---@param bufnr number The buffer number
---@param filetype string The buffer filetype
---@return table Function start/end positions
---@see vim.treesitter.get_node_range
local function get_function_chunk(bufnr, filetype)
  local function_node_name = function_node_names[filetype]

  -- Early return if the filetype is not yet supported
  if not function_node_name then
    vim.g.exemplum.logger:error(
      "The filetype '" .. filetype .. "' isn't currently supported by exemplum.nvim"
    )
    return {}
  end

  -- Get the node at the current cursor position
  local current_node = vim.treesitter.get_node()
  ---@type string
  local function_chunk

  ---@cast current_node -nil
  if current_node:type() == function_node_name then
    function_chunk = vim.treesitter.get_node_text(current_node, bufnr)
  else
    repeat
      if current_node ~= nil then
        current_node = current_node:parent()
      else
        break
      end
    ---@cast current_node -nil
    until current_node ~= nil and current_node:type() == function_node_name

    -- Early return if a function node could not be found
    if not current_node then
      vim.g.exemplum.logger:error(
        "Could not find a function in the current scope: probably your cursor is placed in the wrong scope?"
      )
      return {}
    end

    ---@cast current_node -nil
    function_chunk = vim.treesitter.get_node_text(current_node, bufnr)
  end
  vim.fn.setreg("e", function_chunk)

  return { vim.treesitter.get_node_range(current_node) }
end

---Refactor a function at the cursor position
---@param bang boolean Whether the `:Exemplum` command ran with bang (`!`)
local function refactor_function(bang)
  local code_bufnr = vim.api.nvim_win_get_buf(0)
  local buf_filetype = vim.api.nvim_get_option_value("filetype", { buf = code_bufnr })

  -- Get the function node and save the function code into the `e` register
  local function_range = get_function_chunk(code_bufnr, buf_filetype)

  -- Early return if there was an error during the chunk retrieval process
  if #function_range == 0 then return {} end

  local refactor_register = vim.fn.getreg("e")

  ---@type number
  local ref_bufnr
  if vim.g.exemplum.window.style == "split" then
    ref_bufnr = winbuf.open_split("exemplum_function_refactor", buf_filetype)
  elseif vim.g.exemplum.window.style == "float" then
    ref_bufnr = winbuf.open_float("exemplum_function_refactor", buf_filetype)
  end
  -- Whether to disable diagnostics in the refactoring buffer
  if bang or vim.g.exemplum.disable_diagnostics then
    vim.diagnostic.enable(false, { bufnr = ref_bufnr })
  end
  -- Set the refactor buffer contents
  vim.api.nvim_buf_set_lines(ref_bufnr, 0, -1, false, vim.split(vim.fn.getreg("e"), "\n"))

  -- Avoid autocommands duplication
  if
    #vim.api.nvim_get_autocmds({ group = "Exemplum", pattern = "exemplum_function_refactor" }) < 1
  then
    vim.api.nvim_create_autocmd({ "BufWriteCmd", "BufLeave" }, {
      group = "Exemplum",
      pattern = "exemplum_function_refactor",
      callback = function(ctx)
        if ctx.event == "BufWriteCmd" then
          -- Get the refactor buffer contents and replace the code in the original buffer if it is different from the original code
          local refactor_code = vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)
          if table.concat(refactor_code, "\n") ~= refactor_register then
            vim.api.nvim_buf_set_text(
              code_bufnr,
              function_range[1],
              function_range[2],
              function_range[3],
              function_range[4],
              refactor_code
            )
          end
        end

        -- Disable the modified status while quitting to avoid the save prompts
        vim.api.nvim_set_option_value("modified", false, { buf = ctx.buf })

        -- Deletes the buffer
        if vim.api.nvim_buf_is_loaded(ctx.buf) then vim.cmd.bdelete(ctx.buf) end
      end,
    })
  end
end

return {
  function_node_names = function_node_names,
  refactor = refactor_function,
}
