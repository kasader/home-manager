{ ... }:
{
  # Editors. neovim is the sole editor — "Nix owns the tools, Lua owns the
  # config" — toggle-gated via custom.editors.nvim.enable.
  imports = [
    ./nvim
  ];
}
