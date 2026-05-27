-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "

require("config.options")

-- Auto-load every file under lua/plugins/
require("lazy").setup("plugins")

require("config.keymaps")

-- Apply theme: load persisted choice or fall back to default
local _theme_file = vim.fn.stdpath("data") .. "/colorscheme"
local _saved_theme = vim.fn.filereadable(_theme_file) == 1 and vim.fn.readfile(_theme_file)[1] or nil
require("tokyonight").setup({ style = "night" })
pcall(vim.cmd, "colorscheme " .. (_saved_theme or "tokyonight-night"))

-- Persist colorscheme selection across sessions
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    if vim.g.colors_name then
      vim.fn.writefile({ vim.g.colors_name }, _theme_file)
    end
  end,
})
