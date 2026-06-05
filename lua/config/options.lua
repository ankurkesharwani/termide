vim.opt.termguicolors  = true
vim.opt.title          = true
vim.opt.titlestring    = "TermIDE"
vim.opt.number         = true
vim.opt.relativenumber = true
-- Mouse: load persisted choice or fall back to disabled
local _mouse_file = vim.fn.stdpath("data") .. "/mouse"
local _saved_mouse = vim.fn.filereadable(_mouse_file) == 1 and vim.fn.readfile(_mouse_file)[1] or nil
vim.opt.mouse = _saved_mouse == "enabled" and "a" or ""

vim.api.nvim_create_user_command("MouseEnable", function()
  vim.opt.mouse = "a"
  vim.fn.writefile({ "enabled" }, _mouse_file)
end, {})

vim.api.nvim_create_user_command("MouseDisable", function()
  vim.opt.mouse = ""
  vim.fn.writefile({ "disabled" }, _mouse_file)
end, {})

-- Indentation defaults (overridden per-file by EditorConfig or guess-indent)
vim.opt.expandtab  = true
vim.opt.shiftwidth = 4
vim.opt.tabstop    = 4

-- Code folding (driven by treesitter; files open unfolded)
vim.opt.foldmethod = "expr"
vim.opt.foldexpr   = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = false
vim.opt.foldlevel  = 99

-- Built-in EditorConfig support (reads .editorconfig from project root)
vim.g.editorconfig = true
