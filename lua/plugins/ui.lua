return {
  -- File manager
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { side = "left", width = 30 },
        renderer = { group_empty = true },
        filters = { dotfiles = false },

        -- Remove the default <C-t> behaviour.
        -- When closing terminal using <C-t> focus shifts to nvim-tree
        -- and accidentally using <C-t> once more moved the dir up.
        on_attach = function(bufnr)
          local api = require("nvim-tree.api")
          api.config.mappings.default_on_attach(bufnr)
          vim.keymap.del("n", "<C-t>", { buffer = bufnr })

          -- h / l for folder collapse / expand (file-manager style)
          local opts = function(desc)
            return { buffer = bufnr, silent = true, nowait = true, desc = "nvim-tree: " .. desc }
          end
          vim.keymap.set("n", "l", api.node.open.edit,             opts("open file / expand folder"))
          vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("close parent folder"))
        end,
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
  { "EdenEast/nightfox.nvim",             priority = 1000 },
  { "sainnhe/everforest",                 priority = 1000 },
  { "sainnhe/sonokai",                    priority = 1000 },
  { "projekt0n/github-nvim-theme",        priority = 1000 },
  { "shaunsingh/nord.nvim",               priority = 1000 },

  -- Keybinding helper
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup()
      wk.add({
        { "<leader>f", group = "Find (Telescope)" },
        { "<leader>t", group = "Theme" },
        { "<leader>d", group = "Debug" },
        { "<leader>o", group = "Java: organize" },
        { "<leader>t", group = "Java: test" },
        { "<leader>r", group = "LSP: rename" },
        { "<leader>c", group = "LSP: code action" },
        { "<leader>e", group = "LSP: diagnostics" },
      })
    end,
  },

  -- Terminal
  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("toggleterm").setup({
        size = 15,
        direction = "horizontal",
        open_mapping = [[<C-t>]],
        shade_terminals = true,
        persist_size = true,
      })
    end,
  },

  -- Buffer close without closing the window
  { "famiu/bufdelete.nvim" },

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
              filetype  = "NvimTree",
              text      = "TermIDE",
              highlight = "Directory",
              separator = true,
            },
          },
        },
      })
    end,
  },
}
