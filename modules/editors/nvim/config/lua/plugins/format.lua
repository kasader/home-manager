return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      -- Formatter binaries all come from Nix (programs.neovim.extraPackages).
      formatters_by_ft = {
        go = { "goimports", "gofumpt" },
        nix = { "alejandra" },
        c = { "clang_format" },
        cpp = { "clang_format" },
        lua = { "stylua" },
        yaml = { "prettier" },
        json = { "prettier" },
        markdown = { "prettier" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        toml = { "taplo" },
      },
      format_on_save = { timeout_ms = 1000, lsp_format = "fallback" },
    },
  },
}
