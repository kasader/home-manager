{ ... }:
{
  imports = [
    ../../profiles/home/base.nix
  ];

  home.username = "kasada";
  home.homeDirectory = "/home/kasada";
}
