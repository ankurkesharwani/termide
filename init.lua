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

-- Apply default theme
require("tokyonight").setup({ style = "night" })
pcall(vim.cmd, "colorscheme tokyonight-night")
