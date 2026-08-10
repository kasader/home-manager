{ ... }:
{
  # System-module registry (NixOS only). Mirrors modules/home: importing a module
  # here only *declares* its `custom.*` options — profiles and hosts decide what's
  # on. Nothing in here is ever evaluated on macOS (no nixosConfigurations there).
  imports = [
    ./audio
    ./desktop
  ];
}
