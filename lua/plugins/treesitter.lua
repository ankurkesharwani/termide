local is_nvim_012 = vim.version().minor >= 12

local parsers = {
  "c", "rust", "python", "bash", "make",
  "java", "go", "gomod", "gosum",
  "html", "css", "javascript", "typescript", "tsx",
  "json", "yaml", "toml", "xml",
  "lua", "vim", "vimdoc",
  "markdown", "markdown_inline", -- needed by markview.nvim
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- main branch: Neovim 0.12+ rewrite (highlight/indent are built into Nvim 0.12)
    -- master branch: legacy stable for Neovim 0.11 (nvim-treesitter.configs API)
    branch = is_nvim_012 and "main" or "master",
    lazy = not is_nvim_012, -- main branch does not support lazy loading
    build = ":TSUpdate",
    config = function()
      if is_nvim_012 then
        -- main branch: setup() only takes install_dir; parsers installed separately
        require("nvim-treesitter").install(parsers)
      else
        -- master branch: configs module handles everything
        require("nvim-treesitter.configs").setup({
          ensure_installed = parsers,
          highlight = { enable = true },
          indent    = { enable = true },
        })
      end
    end,
  },
}
