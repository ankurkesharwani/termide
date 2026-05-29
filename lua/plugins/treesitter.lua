return {
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
        "markdown", "markdown_inline",
        "lua", "vim", "vimdoc",
      },
      highlight = { enable = true },
      indent    = { enable = true },
    },
  },
}
