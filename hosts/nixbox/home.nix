{ ... }:
{
  imports = [
    ../../profiles/home/base.nix
  ];

  home.username = "kasada";
  home.homeDirectory = "/home/kasada";

  # Headless host — no browsers or other graphical extras. The base profile
  # already provides the universal (shell, editors, vcs, …) set.
}
