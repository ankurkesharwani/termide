return {
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
          vim.list_extend(bundles, vim.split(debug_jar, "\n"))
        end
        local java_test_path = vim.fn.glob(
          data_path .. "/mason/packages/java-test/extension/server/*.jar"
        )
        if java_test_path ~= "" then
          vim.list_extend(bundles, vim.split(java_test_path, "\n"))
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
          root_dir     = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" }),
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
        pattern  = "java",
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
        pattern  = "*.java",
        callback = function(args)
          local jdtls = require("jdtls")
          local opts  = { buffer = args.buf, silent = true }
          vim.keymap.set("n", "<leader>oi", jdtls.organize_imports,    opts)
          vim.keymap.set("n", "<leader>tc", jdtls.test_class,          opts)
          vim.keymap.set("n", "<leader>tm", jdtls.test_nearest_method, opts)
          jdtls.setup_dap({ hotcodereplace = "auto" })
          vim.defer_fn(function()
            require("jdtls.dap").setup_dap_main_class_configs()
          end, 1000)
        end,
      })
    end,
  },
}
