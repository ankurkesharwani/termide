return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "jay-babu/mason-nvim-dap.nvim",
    },
    config = function()
      local dap   = require("dap")
      local dapui = require("dapui")

      require("mason-nvim-dap").setup({
        ensure_installed = { "codelldb", "python", "java-debug-adapter", "js-debug-adapter" },
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

      -- ─── JavaScript / TypeScript debugging via vscode-js-debug ──────────────
      -- nvim-dap is only a DAP *client*. VSCode ships a config-resolution layer
      -- (legacy-type remap, cwd defaults, runtimeVersion resolution) that nvim
      -- lacks; we reimplement the important parts here via `enrich_config`.
      local js_debug = vim.fn.glob(
        vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"
      )

      if js_debug ~= "" then
        -- Build a `type = "server"` adapter. The `server` type is what lets nvim-dap
        -- reuse this connection for the child sessions vscode-js-debug spawns via
        -- the `startDebugging` reverse request. `rewrite` maps a legacy launch.json
        -- type (node/chrome/msedge) to the pwa-* type the standalone adapter actually
        -- understands (otherwise it errors "Unknown config" and disconnects).
        local function make_adapter(rewrite)
          return {
            type = "server",
            host = "localhost",
            port = "${port}",
            executable = { command = "node", args = { js_debug, "${port}" } },
            enrich_config = function(config, on_config)
              local final = vim.deepcopy(config)
              if rewrite then final.type = rewrite end
              -- VSCode defaults cwd to the workspace folder; the bare adapter does
              -- not, which breaks tools that search upward for config (babel,
              -- tsconfig, .env). Default cwd to Neovim's working directory.
              if not final.cwd then final.cwd = vim.fn.getcwd() end
              on_config(final)
            end,
          }
        end

        -- Canonical (pwa-*) types: just supply the cwd default.
        for _, t in ipairs({ "pwa-node", "pwa-chrome", "pwa-msedge", "pwa-extensionHost", "node-terminal" }) do
          dap.adapters[t] = make_adapter(nil)
        end
        -- Legacy aliases found in most .vscode/launch.json files: remap to pwa-* + cwd.
        for legacy, pwa in pairs({ node = "pwa-node", chrome = "pwa-chrome", msedge = "pwa-msedge" }) do
          dap.adapters[legacy] = make_adapter(pwa)
        end

        -- Make nvim-dap load launch.json entries of these types for JS/TS-family files.
        local js_fts = { "javascript", "typescript", "javascriptreact", "typescriptreact" }
        for _, t in ipairs({ "pwa-node", "node", "pwa-chrome", "chrome", "pwa-msedge", "msedge", "node-terminal" }) do
          vscode.type_to_filetypes[t] = js_fts
        end

        -- Fallback configs so debugging works even with NO .vscode/launch.json.
        -- (If a launch.json exists, its entries are offered in addition to these.)
        for _, ft in ipairs(js_fts) do
          dap.configurations[ft] = dap.configurations[ft] or {}
          vim.list_extend(dap.configurations[ft], {
            {
              type = "pwa-node", request = "launch", name = "Launch current file",
              program = "${file}", cwd = "${workspaceFolder}",
              -- run .ts/.tsx directly; requires `tsx` in the project
              runtimeExecutable = "node", runtimeArgs = { "--import", "tsx" },
              skipFiles = { "<node_internals>/**" },
              sourceMaps = true,
            },
            {
              type = "pwa-node", request = "attach", name = "Attach to process (pick)",
              processId = require("dap.utils").pick_process,
              cwd = "${workspaceFolder}",
              skipFiles = { "<node_internals>/**" },
            },
            {
              type = "pwa-node", request = "attach", name = "Attach on :9229",
              address = "localhost", port = 9229, -- node --inspect default
              cwd = "${workspaceFolder}", skipFiles = { "<node_internals>/**" },
            },
          })
        end
      end

      -- Keymaps
      vim.keymap.set("n", "<F5>",        dap.continue,          { desc = "Debug: continue" })
      vim.keymap.set("n", "<F10>",       dap.step_over,         { desc = "Debug: step over" })
      vim.keymap.set("n", "<F11>",       dap.step_into,         { desc = "Debug: step into" })
      vim.keymap.set("n", "<F12>",       dap.step_out,          { desc = "Debug: step out" })
      vim.keymap.set("n", "<leader>b",   dap.toggle_breakpoint, { desc = "Debug: toggle breakpoint" })
      vim.keymap.set("n", "<leader>du",  dapui.toggle,          { desc = "Debug: toggle UI" })
      vim.keymap.set("n", "<leader>de",  dapui.eval,            { desc = "Debug: evaluate expression" })
      vim.keymap.set("v", "<leader>de",  dapui.eval,            { desc = "Debug: evaluate selection" })

      vim.keymap.set("n", "<leader>da", function()
        local ft = vim.bo.filetype
        -- Rust/C/C++: attach by PID, not port
        if ft == "rust" or ft == "c" or ft == "cpp" then
          dap.run({
            type = "codelldb", request = "attach", name = "Attach",
            pid  = require("dap.utils").pick_process,
          })
          return
        end
        -- Everything else: attach by port
        local port = tonumber(vim.fn.input("Attach port: ", "5005"))
        if not port then return end
        local configs = {
          java       = { type = "java",     request = "attach", name = "Attach", hostName = "127.0.0.1", port = port },
          python     = { type = "python",   request = "attach", name = "Attach", connect = { host = "127.0.0.1", port = port } },
          go         = { type = "go",       request = "attach", name = "Attach", mode = "remote", host = "127.0.0.1", port = port },
          javascript = { type = "pwa-node", request = "attach", name = "Attach", port = port, cwd = vim.fn.getcwd() },
          typescript = { type = "pwa-node", request = "attach", name = "Attach", port = port, cwd = vim.fn.getcwd() },
        }
        local config = configs[ft]
        if config then
          dap.run(config)
        else
          vim.notify("No attach config for filetype: " .. ft, vim.log.levels.WARN)
        end
      end, { desc = "Debug: attach to process" })
    end,
  },
}
