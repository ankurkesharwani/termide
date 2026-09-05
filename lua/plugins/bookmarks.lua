return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      local list_name = "bookmarks"
      local namespace = vim.api.nvim_create_namespace("termide_bookmarks")

      local function current_file()
        local path = vim.api.nvim_buf_get_name(0)
        if path == "" then
          vim.notify("Bookmarks: current buffer has no file", vim.log.levels.WARN)
          return nil
        end
        return vim.fn.fnamemodify(path, ":.")
      end

      local function file_for_buffer(bufnr)
        local path = vim.api.nvim_buf_get_name(bufnr)
        if path == "" then return nil end
        return vim.fn.fnamemodify(path, ":.")
      end

      local function line_text(row)
        local text = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""
        text = text:gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", " ")
        if text == "" then text = "(blank line)" end
        if #text > 80 then text = text:sub(1, 77) .. "..." end
        return text
      end

      local function bookmark_item(kind, row, col)
        local file = current_file()
        if not file then return nil end

        local cursor = vim.api.nvim_win_get_cursor(0)
        row = row or cursor[1]
        col = col or cursor[2]

        return {
          value = file,
          context = {
            kind = kind,
            row = row,
            col = col,
            label = line_text(row),
          },
        }
      end

      local function function_item()
        local ok, node = pcall(vim.treesitter.get_node)
        if not ok or not node then return nil end

        while node do
          local node_type = node:type()
          if node_type:find("function") or node_type:find("method") or node_type:find("constructor") then
            local row, col = node:range()
            return bookmark_item("function", row + 1, col)
          end
          node = node:parent()
        end

        return nil
      end

      local function same_bookmark(a, b)
        if not a or not b then return a == b end
        local ac = a.context or {}
        local bc = b.context or {}
        return a.value == b.value and ac.kind == bc.kind and ac.row == bc.row
      end

      local function find_bookmark(list, item)
        if not item then return nil end
        for i = 1, list:length() do
          if same_bookmark(list:get(i), item) then
            return i
          end
        end
        return nil
      end

      local function refresh_marks(bufnr)
        bufnr = bufnr or vim.api.nvim_get_current_buf()
        local file = file_for_buffer(bufnr)
        if not file then return end

        vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)

        local list = harpoon:list(list_name)
        local line_count = vim.api.nvim_buf_line_count(bufnr)

        for i = 1, list:length() do
          local item = list:get(i)
          local context = item and item.context or {}
          local row = tonumber(context.row)

          if item and item.value == file and row and row >= 1 and row <= line_count then
            local text = context.kind == "function" and "F>" or "B>"
            local highlight = context.kind == "function" and "DiagnosticHint" or "DiagnosticInfo"
            vim.api.nvim_buf_set_extmark(bufnr, namespace, row - 1, 0, {
              virt_text = { { text, highlight } },
              virt_text_pos = "right_align",
              priority = 100,
            })
          end
        end
      end

      local function add_bookmark(item, missing_message)
        if not item then
          vim.notify(missing_message, vim.log.levels.WARN)
          return
        end

        local list = harpoon:list(list_name)
        local exists = find_bookmark(list, item) ~= nil
        list:add(item)

        local action = exists and "Already bookmarked" or "Bookmarked"
        vim.notify(string.format("%s: %s:%d", action, item.value, item.context.row))
        refresh_marks()
      end

      local function remove_bookmark()
        local list = harpoon:list(list_name)
        local line = bookmark_item("line")
        local line_index = find_bookmark(list, line)
        if line_index then
          list:remove(line)
          vim.notify(string.format("Removed bookmark: %s:%d", line.value, line.context.row))
          refresh_marks()
          return
        end

        local fn = function_item()
        local fn_index = find_bookmark(list, fn)
        if fn_index then
          list:remove(fn)
          vim.notify(string.format("Removed bookmark: %s:%d", fn.value, fn.context.row))
          refresh_marks()
          return
        end

        vim.notify("Bookmarks: no line or function bookmark here", vim.log.levels.WARN)
      end

      harpoon:setup({
        settings = {
          save_on_toggle = true,
          sync_on_ui_close = true,
        },
        [list_name] = {
          create_list_item = function()
            return bookmark_item("line")
          end,
          display = function(item)
            local context = item.context or {}
            local kind = context.kind == "function" and "fn" or "line"
            return string.format("%s:%d [%s] %s", item.value, context.row or 1, kind, context.label or "")
          end,
          select = function(item, _, options)
            if not item then return end

            options = options or {}
            if options.vsplit then
              vim.cmd("vsplit")
            elseif options.split then
              vim.cmd("split")
            end

            vim.cmd.edit(vim.fn.fnameescape(item.value))

            local context = item.context or {}
            local row = math.max(1, math.min(context.row or 1, vim.api.nvim_buf_line_count(0)))
            local text = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""
            local col = math.max(0, math.min(context.col or 0, #text))
            vim.api.nvim_win_set_cursor(0, { row, col })
            vim.cmd("normal! zz")
            vim.schedule(refresh_marks)
          end,
          equals = same_bookmark,
        },
      })

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "FocusGained", "WinEnter" }, {
        group = vim.api.nvim_create_augroup("TermideBookmarkMarks", { clear = true }),
        callback = function(args)
          refresh_marks(args.buf)
        end,
      })

      harpoon:extend({
        UI_CREATE = function(cx)
          vim.keymap.set("n", "<C-v>", function()
            harpoon.ui:select_menu_item({ vsplit = true })
          end, { buffer = cx.bufnr, desc = "Open bookmark in vertical split" })

          vim.keymap.set("n", "<C-x>", function()
            harpoon.ui:select_menu_item({ split = true })
          end, { buffer = cx.bufnr, desc = "Open bookmark in horizontal split" })
        end,
      })

      vim.keymap.set("n", "<leader>ma", function()
        add_bookmark(bookmark_item("line"), "Bookmarks: current buffer has no file")
      end, { desc = "Bookmark line" })

      vim.keymap.set("n", "<leader>mf", function()
        add_bookmark(function_item(), "Bookmarks: no containing function or method found")
      end, { desc = "Bookmark function" })

      vim.keymap.set("n", "<leader>ml", function()
        harpoon.ui:toggle_quick_menu(harpoon:list(list_name))
        refresh_marks()
      end, { desc = "List bookmarks" })

      vim.keymap.set("n", "<leader>mr", remove_bookmark, { desc = "Remove bookmark" })
    end,
  },
}
