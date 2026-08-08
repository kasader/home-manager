{ lib, pkgs, ... }:
{
  # Baseline system config every NixOS host gets. The *home* side (shell, git,
  # editors, …) is provided by profiles/home/base.nix via integrated home-manager;
  # this file owns only what must live at the system level.
  #
  # Values below are confirmed against ramiel's installed configuration; the one
  # remaining TODO(ramiel) is declarative password management (see below).
  imports = [ ../../modules/nixos ];

  # Flakes + modern nix CLI.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Locale / timezone. English UI, Japanese formatting (dates, measurements, …).
  time.timeZone = lib.mkDefault "Asia/Tokyo";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ja_JP.UTF-8";
    LC_IDENTIFICATION = "ja_JP.UTF-8";
    LC_MEASUREMENT = "ja_JP.UTF-8";
    LC_MONETARY = "ja_JP.UTF-8";
    LC_NAME = "ja_JP.UTF-8";
    LC_NUMERIC = "ja_JP.UTF-8";
    LC_PAPER = "ja_JP.UTF-8";
    LC_TELEPHONE = "ja_JP.UTF-8";
    LC_TIME = "ja_JP.UTF-8";
  };

  # NixOS owns the *account*; home-manager owns the account's *home*. Fish is the
  # login shell everywhere, so it must be enabled at the system level to be valid.
  programs.fish.enable = true;
  users.users.kasada = {
    isNormalUser = true;
    description = "kasada";
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    # TODO(ramiel): set an initial password with `passwd` after first boot, or
    # manage it declaratively (hashedPasswordFile) once secrets are wired up.
  };

  # Minimal system-level packages; the bulk lives in home-manager.
  environment.systemPackages = with pkgs; [
    git
    vim
  ];
}
