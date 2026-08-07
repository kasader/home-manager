{ ... }:
{
  # NixOS system entry for ramiel. Composes the system profiles; the home side is
  # wired in flake.nix via integrated home-manager (which imports ./home.nix).
  imports = [
    ./hardware-configuration.nix
    ../../profiles/nixos/base.nix
    ../../profiles/nixos/desktop.nix
  ];

  networking.hostName = "ramiel";

  # UEFI machine.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # TODO(ramiel): set this to the NixOS release your machine was installed with.
  # It pins stateful defaults and must NOT be bumped casually — confirm against
  # the `system.stateVersion` in your current /etc/nixos/configuration.nix.
  system.stateVersion = "25.11";
}
