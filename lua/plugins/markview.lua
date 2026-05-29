return {
  -- In-editor Markdown rendering (headings, code blocks, tables, links, etc.)
  {
    "OXY2DEV/markview.nvim",
    -- The author recommends NOT lazy-loading; markview manages its own loading.
    lazy = false,
    dependencies = {
      "nvim-treesitter/nvim-treesitter", -- needs markdown/markdown_inline/html parsers
      "nvim-tree/nvim-web-devicons",     -- icons for code blocks, links, etc.
    },
    config = function()
      require("markview").setup({})

      -- Toggle rendering on/off for the current buffer
      vim.keymap.set("n", "<leader>mv", "<cmd>Markview Toggle<cr>", { desc = "Markview: toggle render" })
    end,
  },
}
