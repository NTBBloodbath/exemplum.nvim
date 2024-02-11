if vim.fn.has("nvim-0.9.0") ~= 1 then
  vim.notify_once("[exemplum.nvim] exemplum.nvim requires at least Neovim >= 0.9 in order to work")
  return
end

if vim.g.loaded_exemplum then
  return
end

vim.g.loaded_exemplum = true
