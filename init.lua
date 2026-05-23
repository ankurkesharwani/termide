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

-- Options (set early so they survive any plugin errors)
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true

require("lazy").setup({
  -- File manager
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { side = "left", width = 30 },
        renderer = { group_empty = true },
        filters = { dotfiles = false },

      })
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          require("nvim-tree.api").tree.open()
          vim.cmd("wincmd l")
        end,
      })
    end,
  },

  -- Colorschemes
  { "folke/tokyonight.nvim",              priority = 1000 },
  { "catppuccin/nvim",       name = "catppuccin", priority = 1000 },
  { "rebelot/kanagawa.nvim",              priority = 1000 },
  { "rose-pine/neovim",      name = "rose-pine",  priority = 1000 },
  { "ellisonleao/gruvbox.nvim",           priority = 1000 },
  { "navarasu/onedark.nvim",              priority = 1000 },

  -- Theme switcher
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          layout_config = { preview_width = 0.6 },
        },
      })
      -- <leader>th opens live-preview colorscheme picker
      vim.keymap.set("n", "<leader>ff", function()
        require("telescope.builtin").find_files()
      end, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", function()
        require("telescope.builtin").live_grep()
      end, { desc = "Search in files" })
      vim.keymap.set("n", "<leader>th", function()
        require("telescope.builtin").colorscheme({ enable_preview = true })
      end, { desc = "Switch theme" })
    end,
  },

  -- Syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    main = "nvim-treesitter",
    opts = {
      ensure_installed = {
        "c", "rust", "python", "bash", "make",
        "java", "go", "gomod", "gosum",
        "html", "css", "javascript", "typescript", "tsx",
        "json", "yaml", "toml", "xml",
        "lua", "vim", "vimdoc",
      },
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  -- Buffer close
  {
    "famiu/bufdelete.nvim",
  },

  -- Buffer tabs at the top
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          custom_filter = function(buf)
            return vim.fn.bufname(buf) ~= ""
          end,
          offsets = {
            {
              filetype = "NvimTree",
              text = "File Explorer",
              highlight = "Directory",
              separator = true,
            },
          },
        },
      })
    end,
  },
})

-- Apply default theme
pcall(vim.cmd, "colorscheme tokyonight-night")

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { silent = true })

-- Toggle file explorer
vim.keymap.set("n", "<C-b>", "<cmd>NvimTreeToggle<CR>", { silent = true })

-- Close current buffer without closing the window
vim.keymap.set("n", "<leader>x", function()
  local is_last = #vim.fn.getbufinfo({ buflisted = 1 }) <= 1
  require("bufdelete").bufdelete(0, false)
  if is_last then pcall(vim.cmd, "q") end
end, { silent = true, desc = "Close buffer" })

-- TAB to cycle through buffers
vim.keymap.set("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { silent = true })
vim.keymap.set("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { silent = true })
