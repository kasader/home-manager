{ pkgs, ... }:
{
  # Baseline nix-darwin system config every macOS host gets. The *home* side
  # (shell, git, editors, …) is provided by profiles/home/base.nix via integrated
  # home-manager; this file owns only what must live at the macOS system level.
  # Mirrors profiles/nixos/base.nix. Per-host bits (hostPlatform, stateVersion,
  # the Homebrew cask/tap lists) live in hosts/<name>/configuration.nix.

  # Flakes + modern nix CLI.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = [ pkgs.vim ];

  # Fish is the login shell on every host. Enabling it at the system level wires
  # nix's environment (set-environment / nix-daemon.fish) into fish startup the
  # same way /etc/zshenv does for zsh, so login fish shells get nix on PATH, and
  # registers it in /etc/shells as a valid login-shell target. The login shell
  # itself is pinned once, imperatively, to /run/current-system/sw/bin/fish via
  # `make israfel-bootstrap` — macOS owns the primary user account, so nix-darwin
  # won't chsh it declaratively. That stable path (vs the old ~/.nix-profile/bin/
  # fish, which a switch can empty) is what prevents the "login shell vanished
  # after rebuild" breakage.
  programs = {
    fish.enable = true;

    # Export ZDOTDIR from /etc/zshenv so zsh finds its config under ~/.config/zsh
    # without a ~/.zshenv bootstrap stub. Pairs with programs.zsh.dotDir in home.
    zsh = {
      enable = true;
      shellInit = ''
        export ZDOTDIR="$HOME/.config/zsh"
      '';
    };
  };
  environment.shells = [ pkgs.fish ];

  # Declarative Homebrew *mechanism*. nix-darwin doesn't install brew itself — it
  # drives the existing install via a generated Brewfile on each rebuild. The
  # cask/tap/brew *lists* are host-specific and live in the host file.
  # cleanup = "none" is the gentle setting: it installs/keeps what's declared and
  # never removes anything installed manually. Flip to "zap" once everything worth
  # keeping is declared, for full reproducibility.
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "none";
      autoUpdate = false;
      upgrade = false;
    };
  };

  # nix-darwin's home-manager integration (useUserPackages) installs into this
  # user's profile, so the user must be declared at the system layer. System
  # activation runs as root; primaryUser scopes user-level options (Homebrew) to
  # this user — required by nix-darwin 25.11 once homebrew.enable is set.
  users.users.kasada = {
    name = "kasada";
    home = "/Users/kasada";
  };
  system.primaryUser = "kasada";
}
