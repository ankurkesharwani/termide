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
vim.opt.number        = true
vim.opt.relativenumber = true

-- Indentation defaults (overridden per-file by EditorConfig or guess-indent)
vim.opt.expandtab  = true
vim.opt.shiftwidth = 4
vim.opt.tabstop    = 4

-- Built-in EditorConfig support (reads .editorconfig from project root)
vim.g.editorconfig = true

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

        -- Remove the default <C-t> behaviour.
        -- Ween closing terminal using <C-t> focus shifts to nvim-tree
        -- and accidently using <C-t> once more moved the dir up.
        on_attach = function(bufnr)
          local api = require("nvim-tree.api")
          api.config.mappings.default_on_attach(bufnr)
          vim.keymap.del("n", "<C-t>", { buffer = bufnr })
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
  { "EdenEast/nightfox.nvim",             priority = 1000 },  -- nightfox, carbonfox, nordfox, dawnfox, duskfox, terafox
  { "sainnhe/everforest",                 priority = 1000 },
  { "sainnhe/sonokai",                    priority = 1000 },
  { "projekt0n/github-nvim-theme",        priority = 1000 },
  { "shaunsingh/nord.nvim",               priority = 1000 },

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

      -- jdtls ships a separate config dir per OS+arch; using the wrong one (e.g.,
      -- config_linux on macOS) leads to subtle breakage in classloader / agent paths
      -- (Lombok stops working, DAP can't resolve runtimes, etc.).
      local jdtls_config_dir = (function()
        local u = vim.uv.os_uname()
        if u.sysname == "Darwin" then
          return u.machine == "arm64" and "config_mac_arm" or "config_mac"
        elseif u.sysname == "Linux" then
          return u.machine:match("arm") and "config_linux_arm" or "config_linux"
        else
          return "config_win"
        end
      end)()

      -- Lower number = preferred when multiple vendors share a major version.
      local vendor_rank = { temurin = 1, corretto = 2, zulu = 3, openjdk = 4, oracle = 5 }

      local function read_release(jdk_path, key)
        local f = io.open(jdk_path .. "/release", "r")
        if not f then return nil end
        for line in f:lines() do
          local v = line:match("^" .. key .. '="(.-)"')
          if v then f:close(); return v end
        end
        f:close()
        return nil
      end

      local function major_version(jdk_path)
        local v = read_release(jdk_path, "JAVA_VERSION")
        if not v then return nil end
        -- "1.8.0_412" -> 8, "21.0.4" -> 21
        if v:match("^1%.") then return tonumber(v:match("^1%.(%d+)")) end
        return tonumber(v:match("^(%d+)"))
      end

      local function vendor_of(jdk_path)
        local v = (read_release(jdk_path, "IMPLEMENTOR") or ""):lower()
        if v:match("adoptium") or v:match("temurin") then return "temurin" end
        if v:match("amazon")   or v:match("corretto") then return "corretto" end
        if v:match("azul")     or v:match("zulu")     then return "zulu" end
        if v:match("oracle") then return "oracle" end
        if v:match("openjdk") then return "openjdk" end
        return "unknown"
      end

      local function discover_runtimes()
        local globs = {
          "/Library/Java/JavaVirtualMachines/*/Contents/Home",
          "/usr/lib/jvm/*",
          vim.fn.expand("~/.sdkman/candidates/java/*"),
          vim.fn.expand("~/.local/share/mise/installs/java/*"),
          vim.fn.expand("~/.asdf/installs/java/*"),
        }

        local java_home = os.getenv("JAVA_HOME")
        local jh_major  = (java_home and vim.fn.isdirectory(java_home) == 1)
                          and major_version(java_home) or nil

        local seen, jdks = {}, {}
        local function add(path, is_java_home)
          local real = vim.fn.resolve(path)
          if seen[real] or vim.fn.isdirectory(real .. "/bin") ~= 1 then return end
          local maj = major_version(real)
          if not maj then return end
          seen[real] = true
          table.insert(jdks, {
            path = real, major = maj, vendor = vendor_of(real),
            is_java_home = is_java_home or false,
          })
        end

        if java_home and jh_major then add(java_home, true) end
        for _, pat in ipairs(globs) do
          for _, p in ipairs(vim.fn.glob(pat, true, true)) do add(p, false) end
        end

        local by_major = {}
        for _, jdk in ipairs(jdks) do
          by_major[jdk.major] = by_major[jdk.major] or {}
          table.insert(by_major[jdk.major], jdk)
        end

        local runtimes = {}
        for maj, list in pairs(by_major) do
          table.sort(list, function(a, b)
            if a.is_java_home ~= b.is_java_home then return a.is_java_home end
            return (vendor_rank[a.vendor] or 99) < (vendor_rank[b.vendor] or 99)
          end)
          table.insert(runtimes, {
            name    = "JavaSE-" .. maj,
            path    = list[1].path,
            default = (jh_major == maj),
          })
        end

        -- No JAVA_HOME? Fall back to marking the newest discovered JDK as default.
        if not jh_major and #runtimes > 0 then
          local best = runtimes[1]
          for _, r in ipairs(runtimes) do
            if tonumber(r.name:match("(%d+)")) > tonumber(best.name:match("(%d+)")) then
              best = r
            end
          end
          best.default = true
        end

        return runtimes
      end

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
            "-configuration", mason_path .. "/" .. jdtls_config_dir,
            "-data", workspace,
          },
          root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" }),
          capabilities = require("cmp_nvim_lsp").default_capabilities(),
          init_options = { bundles = bundles },
          settings = {
            java = {
              eclipse = { downloadSources = true },
              maven   = { downloadSources = true },
              implementationsCodeLens = { enabled = true },
              referencesCodeLens      = { enabled = true },
              configuration = {
                runtimes = discover_runtimes(),
              },
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

      vim.api.nvim_create_user_command("JdtlsClearWorkspace", function()
        local project   = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
        local workspace = data_path .. "/jdtls-workspaces/" .. project

        for _, client in ipairs(vim.lsp.get_clients({ name = "jdtls" })) do
          client.stop()
        end

        vim.fn.delete(workspace, "rf")
        vim.notify("Cleared jdtls workspace: " .. workspace)

        if vim.bo.filetype == "java" then
          start_jdtls()
        end
      end, { desc = "Delete the jdtls workspace for the current project and restart" })

      vim.api.nvim_create_user_command("JdtlsWhichJava", function()
        local lines = {}
        local function add(s) table.insert(lines, s) end

        add("JAVA_HOME: " .. (os.getenv("JAVA_HOME") or "(unset)"))
        add("which java: " .. (vim.fn.exepath("java") ~= "" and vim.fn.exepath("java") or "(not on PATH)"))
        add("")

        local runtimes = discover_runtimes()
        if #runtimes == 0 then
          add("No JDKs discovered.")
        else
          add("Discovered runtimes (jdtls picks by project target version):")
          table.sort(runtimes, function(a, b)
            return tonumber(a.name:match("(%d+)")) < tonumber(b.name:match("(%d+)"))
          end)
          for _, r in ipairs(runtimes) do
            add(string.format("  %s%-12s %s [%s]",
              r.default and "* " or "  ",
              r.name, r.path, vendor_of(r.path)))
          end
          add("")
          add("(* = default runtime when project doesn't declare a target)")
        end

        add("")
        local clients = vim.lsp.get_clients({ name = "jdtls" })
        if #clients == 0 then
          add("jdtls: not attached to any buffer")
        else
          for _, c in ipairs(clients) do
            add(string.format("jdtls (id=%d) root: %s", c.id, c.config.root_dir or "?"))
          end
        end

        vim.notify(table.concat(lines, "\n"))
      end, { desc = "Show which Java runtimes jdtls is configured with" })

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

      local vscode = require("dap.ext.vscode")
      vscode.type_to_filetypes["codelldb"] = { "c", "cpp", "rust" }
      vscode.type_to_filetypes["java"]     = { "java" }

      -- Auto open/close UI with debug session
      dap.listeners.after.event_initialized["dapui"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui"]     = function() dapui.close() end

      -- Keymaps
      vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: continue" })
      vim.keymap.set("n", "<F10>",       dap.step_over,         { desc = "Debug: step over" })
      vim.keymap.set("n", "<F11>",       dap.step_into,         { desc = "Debug: step into" })
      vim.keymap.set("n", "<F12>",       dap.step_out,          { desc = "Debug: step out" })
      vim.keymap.set("n", "<leader>b",   dap.toggle_breakpoint, { desc = "Debug: toggle breakpoint" })
      vim.keymap.set("n", "<leader>du",  dapui.toggle,          { desc = "Debug: toggle UI" })
      vim.keymap.set("n", "<leader>de",  dapui.eval,            { desc = "Debug: evaluate expression" })
      vim.keymap.set("v", "<leader>de",  dapui.eval,            { desc = "Debug: evaluate selection" })
    end,
  },

  -- Auto-detect indentation from file content
  {
    "NMAC427/guess-indent.nvim",
    config = function()
      require("guess-indent").setup({ auto_cmd = true })
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
              text = "TermIDE",
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
pcall(vim.cmd, "colorscheme habamax")

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
