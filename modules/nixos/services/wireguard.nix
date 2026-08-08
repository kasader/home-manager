{ config, lib, ... }:
let
  cfg = config.custom.services.wireguard;
in
{
  options.custom.services.wireguard = {
    enable = lib.mkEnableOption "WireGuard VPN interface";

    interface = lib.mkOption {
      type = lib.types.str;
      default = "wg0";
      description = "Name of the WireGuard interface.";
    };

    address = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      example = [ "10.100.0.1/24" ];
      description = "This host's addresses on the tunnel, with prefix length.";
    };

    listenPort = lib.mkOption {
      type = lib.types.nullOr lib.types.port;
      default = null;
      description = ''
        UDP port to listen on. Set on hosts that accept connections (the always-on
        server); leave null on roaming clients, which pick an ephemeral port.
      '';
    };

    privateKeyFile = lib.mkOption {
      # str, not path: a `path` would be copied into the world-readable Nix store,
      # which is exactly what agenix exists to avoid. This is a runtime location
      # (/run/agenix/...) that need not exist at evaluation time.
      type = lib.types.str;
      description = "Absolute path to the private key, readable only by root.";
    };

    peers = lib.mkOption {
      # Passed through verbatim to networking.wireguard.interfaces.<n>.peers,
      # which type-checks the entries — no point re-declaring that submodule here.
      type = lib.types.listOf (lib.types.attrsOf lib.types.anything);
      default = [ ];
      example = [
        {
          publicKey = "…=";
          allowedIPs = [ "10.100.0.2/32" ];
        }
      ];
      description = "Remote peers permitted on this tunnel.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = cfg.listenPort != null;
      defaultText = lib.literalExpression "cfg.listenPort != null";
      description = "Open listenPort in the firewall. Meaningless without a listenPort.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.address != [ ];
        message = "custom.services.wireguard.address must list at least one tunnel address.";
      }
      {
        assertion = cfg.openFirewall -> cfg.listenPort != null;
        message = "custom.services.wireguard.openFirewall needs a listenPort to open.";
      }
    ];

    networking.wireguard.interfaces.${cfg.interface} = {
      ips = cfg.address;
      inherit (cfg) listenPort privateKeyFile peers;
    };

    networking.firewall.allowedUDPPorts = lib.optional cfg.openFirewall cfg.listenPort;
  };
}
