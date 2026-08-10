return {
  { "nvim-lualine/lualine.nvim", opts = { options = { theme = "catppuccin" } } },
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
  { "numToStr/Comment.nvim", opts = {} },
  { "folke/todo-comments.nvim", dependencies = { "nvim-lua/plenary.nvim" }, opts = {} },
  { "lewis6991/gitsigns.nvim", opts = {} },
  { "nvim-tree/nvim-web-devicons", lazy = true },

  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics (Trouble)" },
    },
  },

  {
    "mbbill/undotree",
    config = function()
      vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Undotree" })
    end,
  },

  { "folke/which-key.nvim", event = "VeryLazy", opts = {} },
}
