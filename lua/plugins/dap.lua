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

      -- Register pwa-node adapter (js-debug-adapter)
      local js_debug = vim.fn.glob(
        vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"
      )
      if js_debug ~= "" then
        dap.adapters["pwa-node"] = {
          type = "server", host = "localhost", port = "${port}",
          executable = { command = "node", args = { js_debug, "${port}" } },
        }
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
