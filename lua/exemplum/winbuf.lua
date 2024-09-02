---@mod exemplum.win exemplum.nvim window and buffer handling
---
---@brief [[
---
---Window and buffer management module of exemplum.nvim
---
---@brief ]]

local winbuf = {}

---Opens a new vertical split window with a new buffer
---
---@param buf_name string The buffer name
---@param filetype string The buffer filetype
---@return number The buffer number
function winbuf.open_split(buf_name, filetype)
  -- Get the buffer number and window ID for the newly created split, as the focus is automatically switched to it
  local ref_bufnr = vim.api.nvim_create_buf(false, true)
  local ref_winid = vim.api.nvim_open_win(ref_bufnr, false, {
    split = "left",
    win = 0,
  })

  -- Set the buffer and window options
  vim.api.nvim_buf_set_name(ref_bufnr, buf_name)
  vim.api.nvim_set_option_value("filetype", filetype, { buf = ref_bufnr })
  vim.api.nvim_set_option_value("buftype", "acwrite", { buf = ref_bufnr })
  vim.api.nvim_set_option_value("bufhidden", "hide", { buf = ref_bufnr })
  vim.api.nvim_set_option_value("buflisted", false, { buf = ref_bufnr })
  vim.api.nvim_set_option_value("signcolumn", "no", { win = ref_winid })

  return ref_bufnr
end

function winbuf.open_float(buf_name, filetype)
  local current_window = vim.api.nvim_get_current_win()

  local ref_bufnr = vim.api.nvim_create_buf(false, true)
  local ref_winid = vim.api.nvim_open_win(ref_bufnr, false, {
    title = (" " .. buf_name:gsub("_", " ")):gsub("%W%l", string.upper):sub(2),
    title_pos = "center",
    border = vim.g.exemplum.window_border,
    style = "minimal",
    relative = "win",
    anchor = vim.api.nvim_win_get_position(current_window)[0] ~= 0 and "NE" or "SE",
    row = 0,
    col = vim.o.columns,
    width = math.floor(vim.api.nvim_win_get_width(0) / 2),
    -- terminal height - cmdline height - statusline height (1) and some small extra padding
    height = vim.api.nvim_win_get_height(0) - vim.o.cmdheight - 2,
  })

  -- Set the buffer options
  vim.api.nvim_buf_set_name(ref_bufnr, buf_name)
  vim.api.nvim_set_option_value("filetype", filetype, { buf = ref_bufnr })
  vim.api.nvim_set_option_value("buftype", "acwrite", { buf = ref_bufnr })

  -- Set focus
  vim.api.nvim_set_current_win(ref_winid)

  return ref_bufnr
end

return winbuf
