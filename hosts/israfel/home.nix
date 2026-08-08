{ ... }: {
  imports = [
    ../../profiles/home/base.nix
    ../../profiles/home/darwin.nix
  ];

  home = {
    username = "kasada";
    homeDirectory = "/Users/kasada";
  };

  # Per-host extras — the base profile already provides the universal set.
  custom = {
    browsers.firefox.enable = true;
    # browsers.librewolf.enable = true;
    k8s.enable = true;
    containers.enable = true;
  };
}
