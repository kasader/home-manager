{
  config,
  lib,
  isDarwin,
  ...
}:
{
  config = lib.mkIf config.custom.shell.enable {
    # Absolute path to this flake, so the `mknix` wrapper (and any rebuild abbr) can
    # drive the Makefile from any directory. Single source of truth: custom.flakeDir.
    home.sessionVariables.NIX_FLAKE = config.custom.flakeDir;

    programs.fish = {
      enable = true;

      # Runs ONLY when creating an interactive shell (not that that matters with fish, really).
      shellInit = ''
        set -U fish_greeting ""
        starship init fish | source
        pay-respects fish --alias | source
      '';

      # Runs for login shells — env/PATH setup that terminals (Alacritty, VSCode, …) inherit.
      #
      # Homebrew is macOS-only: /opt/homebrew doesn't exist on NixOS, and running it
      # unconditionally makes every Linux login shell fail with a startup error.
      loginShellInit = lib.optionalString isDarwin ''
        /opt/homebrew/bin/brew shellenv fish | source
      '';

      shellAliases = import ./aliases.nix;
      shellAbbrs = import ./abbrs.nix;
      functions = import ./functions.nix;
    };
  };
}
