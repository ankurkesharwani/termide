-- Requires Neovim 0.12+: uses the nvim-treesitter "main" branch rewrite.
-- This branch only installs parsers/queries; highlight and indent must be
-- enabled explicitly (they're no longer turned on by a configs.setup call).
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
    branch = "main",
    lazy = false, -- main branch does not support lazy loading
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install(parsers)

      -- Filetype names don't always match parser names (e.g. "sh" -> bash,
      -- "typescriptreact" -> tsx), so try on every filetype and no-op if
      -- there's no parser installed for it.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        callback = function()
          if pcall(vim.treesitter.start) then
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
