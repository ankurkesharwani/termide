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

  -- LSP + completion
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
        automatic_enable = {
          exclude = { "jdtls" },
        },
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
          vim.keymap.set("n", "gd",         vim.lsp.buf.definition,                          opts)
          vim.keymap.set("n", "gI",         require("telescope.builtin").lsp_implementations, opts)
          vim.keymap.set("n", "gr",         require("telescope.builtin").lsp_references,      opts)
          vim.keymap.set("n", "K",          vim.lsp.buf.hover,               opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,              opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action,         opts)
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

  -- Java LSP
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    config = function()
      local data_path  = vim.fn.stdpath("data")
      local mason_path = data_path .. "/mason/packages/jdtls"
      local lombok_jar = data_path .. "/lombok.jar"
      local launcher   = vim.fn.glob(mason_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

      local function start_jdtls()
        local project   = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
        local workspace = data_path .. "/jdtls-workspaces/" .. project

        local bundles = {}
        local debug_jar = vim.fn.glob(
          data_path .. "/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"
        )
        if debug_jar ~= "" then
          table.insert(bundles, debug_jar)
        end

        require("jdtls").start_or_attach({
          cmd = {
            "java",
            "-javaagent:" .. lombok_jar,
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Dosgi.bundles.defaultStartLevel=4",
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            "-Xmx2g",
            "--add-modules=ALL-SYSTEM",
            "--add-opens", "java.base/java.util=ALL-UNNAMED",
            "--add-opens", "java.base/java.lang=ALL-UNNAMED",
            "-jar", launcher,
            "-configuration", mason_path .. "/config_linux",
            "-data", workspace,
          },
          root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
          capabilities = require("cmp_nvim_lsp").default_capabilities(),
          init_options = { bundles = bundles },
          settings = {
            java = {
              eclipse = { downloadSources = true },
              maven   = { downloadSources = true },
              implementationsCodeLens = { enabled = true },
              referencesCodeLens      = { enabled = true },
            },
          },
        })
      end

      -- Called directly for the first Java file (ft = "java" already fired)
      start_jdtls()

      -- Called for every subsequent Java file in the same session
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = start_jdtls,
      })

      -- Java-specific keymaps
      vim.api.nvim_create_autocmd("LspAttach", {
        pattern = "*.java",
        callback = function(args)
          local jdtls = require("jdtls")
          local opts  = { buffer = args.buf, silent = true }
          vim.keymap.set("n", "<leader>oi", jdtls.organize_imports,    opts)
          vim.keymap.set("n", "<leader>tc", jdtls.test_class,          opts)
          vim.keymap.set("n", "<leader>tm", jdtls.test_nearest_method, opts)
          jdtls.setup_dap({ hotcodereplace = "auto" })
          require("jdtls.dap").setup_dap_main_class_configs()
        end,
      })
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

  -- Debugging
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "jay-babu/mason-nvim-dap.nvim",
    },
    config = function()
      local dap    = require("dap")
      local dapui  = require("dapui")

      require("mason-nvim-dap").setup({
        ensure_installed = { "codelldb", "python", "java-debug-adapter" },
        handlers = {},
      })

      dapui.setup()

      -- Auto open/close UI with debug session
      dap.listeners.after.event_initialized["dapui"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui"]     = function() dapui.close() end

      -- Keymaps
      vim.keymap.set("n", "<F5>", function()
        local launch = vim.fn.getcwd() .. "/.vscode/launch.json"
        if vim.fn.filereadable(launch) == 1 then
          require("dap.ext.vscode").load_launchjs(launch, { codelldb = { "c", "cpp", "rust" } })
        end
        dap.continue()
      end, { desc = "Debug: continue" })
      vim.keymap.set("n", "<F10>",       dap.step_over,         { desc = "Debug: step over" })
      vim.keymap.set("n", "<F11>",       dap.step_into,         { desc = "Debug: step into" })
      vim.keymap.set("n", "<F12>",       dap.step_out,          { desc = "Debug: step out" })
      vim.keymap.set("n", "<leader>b",   dap.toggle_breakpoint, { desc = "Debug: toggle breakpoint" })
      vim.keymap.set("n", "<leader>du",  dapui.toggle,          { desc = "Debug: toggle UI" })
      vim.keymap.set("n", "<leader>de",  dapui.eval,            { desc = "Debug: evaluate expression" })
      vim.keymap.set("v", "<leader>de",  dapui.eval,            { desc = "Debug: evaluate selection" })
    end,
  },

  -- Keybinding helper
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup()
      wk.add({
        { "<leader>f",  group = "Find (Telescope)" },
        { "<leader>t",  group = "Theme" },
        { "<leader>d",  group = "Debug" },
        { "<leader>o",  group = "Java: organize" },
        { "<leader>t",  group = "Java: test" },
        { "<leader>r",  group = "LSP: rename" },
        { "<leader>c",  group = "LSP: code action" },
        { "<leader>e",  group = "LSP: diagnostics" },
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

-- Exit terminal insert mode with Esc
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { silent = true })

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
