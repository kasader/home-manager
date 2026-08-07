{ pkgs, ... }:
{
  # NixOS system entry for nixbox — a headless Linode VPS. Composes the system
  # profiles; the home side is wired in flake.nix via integrated home-manager
  # (which imports ./home.nix). No desktop profile: base only.
  #
  # Anything already provided by profiles/nixos/base.nix (fish login shell, the
  # kasada account, locale/timezone, NetworkManager, flakes) is deliberately not
  # restated here.
  imports = [
    ./hardware-configuration.nix
    ../../profiles/nixos/base.nix
  ];

  # BIOS machine. The GRUB device, serial console, and timeout that Linode's image
  # needs ship in hardware-configuration.nix alongside the rest of the hardware.
  boot.loader.grub.enable = true;

  networking = {
    hostName = "nixbox";

    # Linode's network setup: unpredictable interface names (eth0), no global
    # DHCP, DHCP on eth0 only.
    usePredictableInterfaceNames = false;
    useDHCP = false;
    interfaces.eth0.useDHCP = true;
  };

  # Key-only SSH — this box is on the public internet.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # The kasada account is declared in profiles/nixos/base.nix; SSH keys are
  # host-specific, so they attach here. This is also what makes the account
  # reachable at all — base.nix sets no password.
  users.users.kasada.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGTzdbcvGlOFncCHcBN91i/JvY1X9YBmj1ZNhbElfv+e sasha@diarkis.io"
  ];

  security.sudo.wheelNeedsPassword = false;

  # Server-side diagnostics, on top of base.nix's git/vim. enableAllTerminfo so
  # sessions from arbitrary terminal emulators render correctly over SSH.
  environment.systemPackages = with pkgs; [
    inetutils
    mtr
    sysstat
  ];
  environment.enableAllTerminfo = true;

  # Carried over verbatim from the machine's own /etc/nixos/configuration.nix.
  # Pins stateful defaults to the release nixbox was installed with — do not bump.
  system.stateVersion = "26.05";
}
