{ config, ... }:
let
  tunnel = import ../tunnel.nix;

  port = 5000;
  libraryDir = "/srv/library";
  libraryGroup = "kavita"; # created by the upstream kavita module
in
{
  # Reachable at http://kavita.vpn:5000 over the tunnel only. Plain HTTP is fine —
  # WireGuard already encrypts the path, and a .vpn name can't hold a publicly
  # trusted certificate anyway. TLS arrives with nginx and a real domain.
  services.kavita = {
    enable = true;
    tokenKeyFile = config.age.secrets.kavita-token.path;
    settings = {
      Port = port;
      # Deliberately not 0.0.0.0 (the upstream default): a private service should
      # not have a socket on the public interface at all, firewall or no firewall.
      IpAddresses = tunnel.addr;
    };
  };

  # The bind address only exists once the tunnel is up, and binding a missing
  # address fails outright. Ordering after the interface unit means Kavita starts
  # when there is something to bind to — and stays down while the VPN is, which is
  # correct for a VPN-only service.
  systemd.services.kavita = {
    after = [ tunnel.unit ];
    requires = [ tunnel.unit ];
  };

  # Books live outside kavita's dataDir (/var/lib/kavita), which holds the database
  # and covers. Keeping them apart means attaching a block-storage volume later is
  # just mounting it here: no config change, no re-scan.
  #
  # 2775: setgid, so anything uploaded inherits libraryGroup rather than the
  # uploader's primary group — otherwise Kavita silently can't read new files.
  # Group-writable so a human can rsync in without becoming root.
  systemd.tmpfiles.rules = [
    "d ${libraryDir} 2775 ${config.services.kavita.user} ${libraryGroup} - -"
  ];
  users.users.kasada.extraGroups = [ libraryGroup ];

  networking.firewall.interfaces.${tunnel.iface}.allowedTCPPorts = [ port ];
}
