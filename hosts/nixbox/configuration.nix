{ pkgs, ... }:
{
  # NixOS system entry for nixbox — a headless Linode VPS. The home side is wired
  # in flake.nix via integrated home-manager (which imports ./home.nix). The
  # services this box actually runs live in ./services.nix.
  #
  # Anything already provided by profiles/nixos/base.nix (fish login shell, the
  # kasada account, locale/timezone, flakes) is deliberately not restated here.
  imports = [
    ./hardware-configuration.nix
    ./services.nix
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

  # Decrypted at activation into /run/agenix using this host's
  # /etc/ssh/ssh_host_ed25519_key. Never enters the Nix store.
  age.secrets = {
    wireguard-nixbox-private.file = ../../secrets/wireguard-nixbox-private.age;
    kavita-token = {
      file = ../../secrets/kavita-token.age;
      # systemd reads this via LoadCredential as root before dropping to the
      # kavita user, so it does not need to be owned by that user.
      mode = "0400";
    };
  };

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
