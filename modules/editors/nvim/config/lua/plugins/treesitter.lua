return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "go", "gomod", "gosum", "gowork",
          "nix",
          "c", "cpp",
          "lua", "vim", "vimdoc",
          "yaml", "json", "jsonc",
          "dockerfile", "bash",
          "markdown", "markdown_inline", "toml",
        },
        auto_install = false, -- grammars come from the pinned list above, not on the fly
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
}
