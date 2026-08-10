{ ... }:
{
  # The terminal environment: emulator + multiplexer, each toggle-gated
  # (custom.terminal.ghostty.enable, custom.terminal.tmux.enable). Room for more.
  imports = [
    ./ghostty.nix
    ./tmux.nix
  ];
}
