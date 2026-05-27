-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { silent = true })

-- Window resize submode: <leader>w enters; then tap keys repeatedly without
-- re-pressing the prefix. h/l = width, j/k = height, = equalize, q/<Esc> exit.
vim.keymap.set("n", "<leader>w", function()
  local step = 3
  local hint = "-- RESIZE --  h/l: width   j/k: height   =: equalize   q/<Esc>: exit"

  -- Save nvim-tree width after each horizontal resize so restores use the right value
  local function sync_tree_width()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "NvimTree" then
        vim.g._nvim_tree_width = vim.api.nvim_win_get_width(win)
        return
      end
    end
  end

  while true do
    vim.cmd("redraw")               -- repaint so the previous resize is visible
    vim.api.nvim_echo({ { hint, "ModeMsg" } }, false, {})
    local ok, ch = pcall(vim.fn.getcharstr)
    if not ok then break end
    if ch == "h" then
      vim.cmd("vertical resize -" .. step)
      sync_tree_width()
    elseif ch == "l" then
      vim.cmd("vertical resize +" .. step)
      sync_tree_width()
    elseif ch == "j" then
      vim.cmd("resize -" .. step)
    elseif ch == "k" then
      vim.cmd("resize +" .. step)
    elseif ch == "=" then
      vim.cmd("wincmd =")
      sync_tree_width()
    else
      break -- q, <Esc>, or any other key exits
    end
  end
  vim.api.nvim_echo({ { "" } }, false, {}) -- clear the hint line
end, { silent = true, desc = "Window resize mode" })

-- Exit terminal insert mode with Esc
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { silent = true })

-- Toggle file explorer
vim.keymap.set("n", "<C-b>", "<cmd>NvimTreeToggle<CR>", { silent = true })

-- Code folding shortcuts: <leader>z<N> sets foldlevel to N (0 = fully folded, 9 ~= fully open)
for i = 0, 9 do
  vim.keymap.set("n", "<leader>z" .. i, function()
    vim.opt.foldenable = true
    vim.opt.foldlevel  = i
  end, { silent = true, desc = "Fold to level " .. i })
end

-- Close current buffer without closing the window
vim.keymap.set("n", "<leader>x", function()
  local is_last = #vim.fn.getbufinfo({ buflisted = 1 }) <= 1
  require("bufdelete").bufdelete(0, false)
  if is_last then pcall(vim.cmd, "q") end
end, { silent = true, desc = "Close buffer" })

-- TAB to cycle through buffers
vim.keymap.set("n", "<Tab>",   "<cmd>BufferLineCycleNext<CR>", { silent = true })
vim.keymap.set("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { silent = true })

-- :Guide — open this config's GUIDE.md as a read-only buffer
vim.api.nvim_create_user_command("Guide", function()
  vim.cmd.edit(vim.fn.stdpath("config") .. "/GUIDE.md")
  vim.bo.modifiable = false
  vim.bo.readonly   = true
end, { desc = "Open the Neovim usage guide (read-only)" })

-- :FindMethods — list method/function definitions via LSP document symbols
vim.api.nvim_create_user_command("FindMethods", function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    vim.notify("FindMethods: no LSP attached", vim.log.levels.WARN)
    return
  end
  require("telescope.builtin").lsp_document_symbols({
    symbols = { "method", "function", "constructor" },
  })
end, { desc = "List methods/functions in current buffer (LSP)" })

vim.keymap.set("n", "<leader>fm", "<cmd>FindMethods<CR>",
  { silent = true, desc = "Find methods/functions in current buffer" })
