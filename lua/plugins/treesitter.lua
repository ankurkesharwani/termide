return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- Pinned to master explicitly. master is the legacy/stable branch the project
    -- maintains for Neovim 0.11; the `main` rewrite requires Neovim 0.12 (nightly).
    -- Pinning also stops `Lazy sync` from auto-switching branches on us.
    branch = "master",
    build = ":TSUpdate",
    config = function()
      -- On master the configuration entry point is `nvim-treesitter.configs`.
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "c", "rust", "python", "bash", "make",
          "java", "go", "gomod", "gosum",
          "html", "css", "javascript", "typescript", "tsx",
          "json", "yaml", "toml", "xml",
          "lua", "vim", "vimdoc",
          "markdown", "markdown_inline", -- needed by markview.nvim
        },
        highlight = { enable = true },
        indent    = { enable = true },
      })
    end,
  },
}
