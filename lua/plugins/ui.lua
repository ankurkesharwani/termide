return {
  -- File manager
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- Width is saved by the <leader>w resize submode (keymaps.lua) into
      -- vim.g._nvim_tree_width so it survives toggle and new-split reflows.
      local _width_file = vim.fn.stdpath("data") .. "/nvim_tree_width"
      vim.g._nvim_tree_width = vim.fn.filereadable(_width_file) == 1
        and tonumber(vim.fn.readfile(_width_file)[1]) or 50

      local function restore_tree_width()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "NvimTree" then
            vim.api.nvim_win_set_width(win, vim.g._nvim_tree_width)
            return
          end
        end
      end

      -- Restore after toggle-open (tree closed then reopened)
      vim.api.nvim_create_autocmd("BufWinEnter", {
        callback = function()
          if vim.bo.filetype == "NvimTree" then
            vim.schedule(restore_tree_width)
          end
        end,
      })

      -- Restore after the first file is opened (creates a new split, Vim rebalances).
      -- Called synchronously so the width is fixed before the first redraw — no flicker.
      vim.api.nvim_create_autocmd("WinNew", {
        callback = restore_tree_width,
      })

      require("nvim-tree").setup({
        view = { side = "left", width = vim.g._nvim_tree_width },
        actions = { open_file = { resize_window = false } },
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
  { "folke/tokyonight.nvim",                           priority = 1000 },
  { "rebelot/kanagawa.nvim",                           priority = 1000 },
  { "EdenEast/nightfox.nvim",                          priority = 1000 },
  { "catppuccin/nvim",            name = "catppuccin", priority = 1000 },
  { "rose-pine/neovim",           name = "rose-pine",  priority = 1000 },
  { "navarasu/onedark.nvim",                           priority = 1000 },
  { "sainnhe/everforest",                              priority = 1000 },
  { "sainnhe/sonokai",                                 priority = 1000 },
  { "projekt0n/github-nvim-theme",                     priority = 1000 },
  { "marko-cerovac/material.nvim",                     priority = 1000 },
  { "Shatur/neovim-ayu",                               priority = 1000 },
  { "olivercederborg/poimandres.nvim",                 priority = 1000 },
  { "savq/melange-nvim",                               priority = 1000 },
  { "sam4llis/nvim-tundra",                            priority = 1000 },
  { "datsfilipe/vesper.nvim",                          priority = 1000 },
  { "oxfist/night-owl.nvim",                           priority = 1000 },
  { "dgox16/oldworld.nvim",                            priority = 1000 },
  { "uloco/bluloco.nvim",  dependencies = { "rktjmp/lush.nvim" }, priority = 1000 },
  { "vague-theme/vague.nvim",                          priority = 1000 },

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
