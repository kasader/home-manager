{ ... }:
{
  # base only for now. profiles/home/workstation.nix presumes a graphical
  # session, so it belongs here once this host has one at the system level —
  # see the desktop note in ./configuration.nix.
  imports = [
    ../../profiles/home/base.nix
  ];

  home.username = "kasada";
  home.homeDirectory = "/home/kasada";
}
