return { {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          layout_config = { preview_width = 0.6 },
        },
      })
      vim.keymap.set("n", "<leader>ff", function()
        require("telescope.builtin").find_files()
      end, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", function()
        require("telescope.builtin").live_grep()
      end, { desc = "Search in files" })
      vim.keymap.set("n", "<leader>th", function()
        require("telescope.builtin").colorscheme({ enable_preview = true })
      end, { desc = "Switch theme" })
      vim.keymap.set("n", "<leader>ts", function()
        local styles = { "default", "atlantis", "andromeda", "shusia", "maia", "espresso" }
        vim.ui.select(styles, { prompt = "Sonokai style:" }, function(choice)
          if choice then
            vim.g.sonokai_style = choice
            vim.cmd("colorscheme sonokai")
            vim.fn.writefile({ choice }, vim.fn.stdpath("data") .. "/sonokai_style")
          end
        end)
      end, { desc = "Sonokai style" })
    end,
  },
}
