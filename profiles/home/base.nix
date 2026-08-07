{ config, pkgs, ... }:
{
  # The base profile: everything that belongs on *every* machine. It pulls in the
  # full module registry (so all `custom.*` options exist) and switches on the
  # universal set. Per-host extras are enabled in the host files instead.
  imports = [ ../../modules/home ];

  programs.home-manager.enable = true;

  custom = {
    cloud = {
      aws.enable = true;
      gcp.enable = true;
      oci.enable = true;
    };
    fonts.enable = true;
    security.enable = true;
    media.enable = true;
    fun.enable = true;
    editors.nvim.enable = true;
    shell = {
      enable = true;
      fzf.enable = true;
    };
    terminal = {
      ghostty.enable = true;
      tmux.enable = true;
    };
    vcs = {
      git.enable = true;
      ghq.enable = true;
    };
    files.yazi.enable = true;
    services.syncthing.enable = true;
    languages = {
      go.enable = true;
      rust.enable = true;
      python3.enable = true;
    };
  };

  home = {
    # Universal misc CLI tools that don't warrant a topical module. Themed sets
    # live in their own modules instead: security, media, fun (toys/typing), vcs,
    # languages, etc. — see the custom.* toggles above. delta and direnv are NOT
    # listed here: they ship via programs.delta (vcs/git) and programs.direnv.
    packages = with pkgs; [
      hugo
      gnugrep
      gnumake
      ripgrep
      fastfetch # TODO: Add an alias for neofetch (as it is now deprecated)
      bat
      pay-respects
      lazygit
      htop
      jq
      nixfmt
      tree
      wget
      tldr
      curl
      colordiff
      icdiff

      # Migrated off Homebrew (`brew leaves`). Stable, cross-platform CLI tools
      # that nix packages cleanly. Build toolchains (cmake/meson/llvm/golangci-lint
      # /mage/doxygen) deliberately stay out of the global env and belong in each
      # project's dev-shell instead.
      gh
      coreutils
      ncdu
      nmap
      socat
      inetutils # provides telnet
      aria2
      shfmt
      stylua
      universal-ctags
      graphviz
      bashInteractive
      watch

      # TODO: Add Soulseek server-client (at some point...)
      # https://github.com/slskd/slskd/

      # TODO: Good OCR for when you need to do JPNs something?
      # tesseract
    ];

    sessionVariables = {
      EDITOR = "nvim";
      MANWIDTH = "100";
      DIARKIS_PATH = "${config.home.homeDirectory}/diarkis";
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
