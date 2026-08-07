{ lib, ... }:
{
  imports = [
    ../../profiles/home/base.nix
  ];

  home.username = "kasada";
  home.homeDirectory = "/home/kasada";

  # Headless host: peel back the graphical bits the base profile switches on for
  # workstations. mkForce because base.nix sets these to a plain `true`, not a
  # mkDefault — a bare `false` here would be a conflicting definition, not an
  # override. Ghostty on Linux builds the real GUI terminal, and the font set only
  # matters where something renders; neither has a consumer over SSH.
  custom.terminal.ghostty.enable = lib.mkForce false;
  custom.fonts.enable = lib.mkForce false;
}
