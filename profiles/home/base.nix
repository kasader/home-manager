{ pkgs, ... }:
{
  # Core home profile: interactive environment for any machine I use including
  # any sort of headless env.
  imports = [ ../../modules/home ];

  programs.home-manager.enable = true;

  custom = {
    editors.nvim.enable = true;
    files.yazi.enable = true;
    shell = {
      enable = true;
      fzf.enable = true;
    };
    terminal.tmux.enable = true;
    vcs = {
      git.enable = true;
      ghq.enable = true;
    };
  };

  home = {
    # Core toolbelt
    packages = with pkgs; [
      bashInteractive
      bat
      coreutils
      curl
      fastfetch
      gnugrep
      gnumake
      htop
      inetutils # provides telnet
      jq
      lazygit
      ncdu
      nix-search-cli # `nix-search`; backs pay-respects' package suggestions
      pay-respects # the fish module sources this unconditionally
      ripgrep
      tldr
      tree
      watch
      wget
    ];

    sessionVariables = {
      EDITOR = "nvim";
      MANWIDTH = "100";
    };

    # Per-language install dirs (Go GOBIN, cargo CARGO_INSTALL_ROOT) target
    # ~/.local/bin, so no language-specific bin dirs are needed here.
    sessionPath = [
      "$HOME/.local/bin"
    ];

    # This value determines the Home Manager release that
    # this configuration is compatible with. It helps to
    # avoid breakage when a new Home Manage release
    # introduces backwards incompatible changes.
    stateVersion = "25.11";
  };

  # TODO: Move this to its own standalone module (if it is needed).
  programs.direnv = {
    enable = true;
    # FIXME: It seems like if you have 'enable = true;' then you don't need to configure your
    # options per shell.
    # enableFishIntegration = true;
    nix-direnv.enable = true;
    config = {
      global = {
        hide_env_diff = true;
      };
    };
  };
}
