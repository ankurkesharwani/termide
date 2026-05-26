vim.opt.termguicolors  = true
vim.opt.number         = true
vim.opt.relativenumber = true

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
