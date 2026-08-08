{ config, lib, ... }:
let
  cfg = config.custom.services.dns;
in
{
  options.custom.services.dns = {
    enable = lib.mkEnableOption "dnsmasq resolver for the private network";

    interface = lib.mkOption {
      type = lib.types.str;
      default = "wg0";
      description = ''
        The only interface dnsmasq answers on. Combined with bind-interfaces this
        keeps the resolver off the public interface — an open resolver reachable
        from the internet gets conscripted into DNS amplification attacks.
      '';
    };

    localDomain = lib.mkOption {
      type = lib.types.str;
      default = "vpn";
      description = "Suffix served locally; everything under it resolves to localAddress.";
    };

    localAddress = lib.mkOption {
      type = lib.types.str;
      example = "10.100.0.1";
      description = "Address that *.<localDomain> resolves to.";
    };

    upstreams = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "1.1.1.1"
        "9.9.9.9"
      ];
      description = "Resolvers to forward all non-local queries to.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.dnsmasq = {
      enable = true;
      settings = {
        inherit (cfg) interface;

        # Bind only the named interface rather than the wildcard address. Without
        # this dnsmasq binds 0.0.0.0 and merely filters by interface, so anything
        # that bypasses the filter reaches a live socket on the public IP.
        bind-interfaces = true;

        # Wildcard: *.vpn (and bare `vpn`) -> localAddress.
        address = [ "/${cfg.localDomain}/${cfg.localAddress}" ];

        server = cfg.upstreams;

        # Never read /etc/resolv.conf for upstreams. If this host's own resolver
        # is ever pointed here, inheriting it would make dnsmasq forward to
        # itself — an infinite loop that presents as "DNS is just broken".
        no-resolv = true;

        # Don't forward junk upstream: unqualified single-label names, and
        # reverse lookups for RFC1918 space that public resolvers can't answer.
        domain-needed = true;
        bogus-priv = true;

        cache-size = 1000;
      };
    };

    # Port 53 opened ONLY on the tunnel, never globally. DNS needs TCP as well as
    # UDP — responses larger than 512 bytes fall back to TCP.
    networking.firewall.interfaces.${cfg.interface} = {
      allowedUDPPorts = [ 53 ];
      allowedTCPPorts = [ 53 ];
    };
  };
}
