{ ... }:
{
  # Long-running user services (launchd on macOS, systemd-user on Linux). Each
  # declares its own custom.services.<name> toggle; room here for more later.
  imports = [
    ./syncthing.nix
  ];
}
