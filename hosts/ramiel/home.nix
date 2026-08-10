{ ... }: {
  imports = [
    ../../profiles/home/base.nix
    ../../profiles/home/workstation.nix
  ];

  home.username = "kasada";
  home.homeDirectory = "/home/kasada";

  # Per-host extras — the base profile already provides the universal set.
  custom.browsers.firefox.enable = true;
  # custom.browsers.librewolf.enable = true;
}
