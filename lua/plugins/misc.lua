return {
  -- Auto-detect indentation from file content
  {
    "NMAC427/guess-indent.nvim",
    config = function()
      require("guess-indent").setup({ auto_cmd = true })
    end,
  },

  -- Git integration: :Git <command>, handles rebase/commit editors natively
  { "tpope/vim-fugitive" },

  -- Diff viewer and merge tool
  {
    "sindrets/diffview.nvim",
    config = function()
      require("diffview").setup()
      vim.keymap.set("n", "<leader>gD", "<cmd>DiffviewOpen<cr>",          { desc = "Diffview open" })
      vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "File history" })
      vim.keymap.set("n", "<leader>gq", "<cmd>DiffviewClose<cr>",         { desc = "Diffview close" })
    end,
  },

  -- Git change indicators in the sign column
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "▎" },
          change       = { text = "▎" },
          delete       = { text = "" },
          topdelete    = { text = "" },
          changedelete = { text = "▎" },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local map = function(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
          end
          map("n", "]h", gs.next_hunk,        "Next git hunk")
          map("n", "[h", gs.prev_hunk,        "Prev git hunk")
          map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
          map("n", "<leader>hr", gs.reset_hunk,   "Reset hunk")
          map("n", "<leader>hs", gs.stage_hunk,   "Stage hunk")
          map("n", "<leader>hb", gs.blame_line,   "Blame line")
        end,
      })
    end,
  },
}
