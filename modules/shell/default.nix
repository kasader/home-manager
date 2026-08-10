{ lib, ... }:
{
  # One toggle for the whole shell stack — fish, zsh and starship are
  # co-installed rather than alternatives, so they share a single enable flag
  # that each child gates its config on. bash is included only as a script
  # interpreter (no interactive config).
  options.custom.shell.enable = lib.mkEnableOption "shell stack (fish, zsh, starship; bash as interpreter)";

  imports = [
    ./bash/default.nix
    ./fish/default.nix
    ./zsh/default.nix
    ./starship/default.nix
    # fzf is shell-tier (interactive fuzzy finder, per-shell integration) but
    # keeps its own custom.shell.fzf.enable toggle rather than folding into
    # custom.shell.enable.
    ./fzf/default.nix
  ];
}
