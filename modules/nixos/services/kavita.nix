{ config, lib, ... }:
let
  cfg = config.custom.services.kavita;
in
{
  options.custom.services.kavita = {
    enable = lib.mkEnableOption "Kavita reading server";

    port = lib.mkOption {
      type = lib.types.port;
      default = 5000;
      description = "Port Kavita listens on.";
    };

    bindAddress = lib.mkOption {
      type = lib.types.str;
      example = "10.100.0.1";
      description = ''
        Address to listen on. Deliberately not 0.0.0.0 (the upstream default):
        this is a private service, so it should not have a socket open on the
        public interface at all, firewall or no firewall.
      '';
    };

    interface = lib.mkOption {
      type = lib.types.str;
      default = "wg0";
      description = "Interface the port is opened on, and which must be up first.";
    };

    tokenKeyFile = lib.mkOption {
      # str rather than path so an agenix runtime location can be passed without
      # being copied into the world-readable store.
      type = lib.types.str;
      description = "File holding Kavita's 512+ bit TokenKey.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.kavita = {
      enable = true;
      inherit (cfg) tokenKeyFile;
      settings = {
        Port = cfg.port;
        IpAddresses = cfg.bindAddress;
      };
    };

    # bindAddress only exists once the tunnel is up, and binding a missing
    # address fails outright. Ordering after the interface unit means Kavita
    # starts when there is something to bind to — and stays down if the VPN is
    # down, which is correct for a VPN-only service.
    systemd.services.kavita = {
      after = [ "wireguard-${cfg.interface}.service" ];
      requires = [ "wireguard-${cfg.interface}.service" ];
    };

    # Second layer behind the bind address: reachable only over the tunnel.
    networking.firewall.interfaces.${cfg.interface}.allowedTCPPorts = [ cfg.port ];
  };
}
