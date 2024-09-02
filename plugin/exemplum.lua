if vim.version().minor < 10 then
  vim.notify_once(
    "[exemplum.nvim] ERROR: exemplum.nvim requires at least Neovim >= 0.10 in order to work",
    vim.log.levels.ERROR
  )
  return
end

if vim.g.loaded_exemplum then
  return
end

require("exemplum.internal").load()

vim.g.loaded_exemplum = true
