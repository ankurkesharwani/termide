return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "clangd", "rust_analyzer", "pyright", "bashls",
          "ts_ls", "html", "cssls", "lua_ls", "jdtls",
        },
        -- Keep LSP attachment controlled by the explicit vim.lsp.enable() list
        -- below, instead of enabling every Mason-installed server.
        automatic_enable = false,
      })

      -- Completion
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args) require("luasnip").lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<Tab>"]     = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item() else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"]   = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item() else fallback() end
          end, { "i", "s" }),
          ["<C-e>"]     = cmp.mapping.abort(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })

      -- LSP keymaps + capabilities
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      vim.lsp.config("*", { capabilities = capabilities })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local opts = { buffer = args.buf, silent = true }
          vim.keymap.set("n", "gd",         vim.lsp.buf.definition,                           opts)
          vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition,
            vim.tbl_extend("force", opts, { desc = "Go to definition" }))
          vim.keymap.set("n", "gI",         require("telescope.builtin").lsp_implementations,  opts)
          vim.keymap.set("n", "gr",         require("telescope.builtin").lsp_references,       opts)
          vim.keymap.set("n", "K",          vim.lsp.buf.hover,               opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,              opts)
          vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>e",  vim.diagnostic.open_float,       opts)
          vim.keymap.set("n", "]d",         vim.diagnostic.goto_next,        opts)
          vim.keymap.set("n", "[d",         vim.diagnostic.goto_prev,        opts)
        end,
      })

      for _, server in ipairs({
        "clangd", "rust_analyzer", "pyright", "bashls",
        "ts_ls", "html", "cssls", "lua_ls",
      }) do
        vim.lsp.enable(server)
      end
    end,
  },
}
