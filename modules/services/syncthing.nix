{ config, lib, ... }:
let
  cfg = config.custom.services.syncthing;
in
{
  options.custom.services.syncthing.enable = lib.mkEnableOption "Syncthing file synchronisation";

  config = lib.mkIf cfg.enable {
    # Run Syncthing as a user service (launchd on macOS, systemd-user on Linux),
    # auto-starting at login and restarting on crash. Folders and devices are
    # managed in the Web UI (http://127.0.0.1:8384), not declaratively, so changes
    # made there persist across rebuilds.
    services.syncthing.enable = true;
  };
}
