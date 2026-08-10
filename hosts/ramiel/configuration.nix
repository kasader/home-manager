{ ... }:
{
  # NixOS system entry for ramiel.
  imports = [
    ./hardware-configuration.nix
    ./desktop.nix
    ../../profiles/nixos/base.nix
  ];

  # Network configuration.
  networking = {
    hostName = "ramiel";
    networkmanager.enable = true;
  };
  users.users.kasada.extraGroups = [ "networkmanager" ];

  # UEFI machine.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # TODO(ramiel): set this to the NixOS release your machine was installed with.
  # It pins stateful defaults and must NOT be bumped casually — confirm against
  # the `system.stateVersion` in your current /etc/nixos/configuration.nix.
  system.stateVersion = "25.11";
}
