{ ... }:
let
  tunnel = import ../tunnel.nix;
in
{
  # Resolver for the tunnel: *.vpn -> nixbox, everything else forwarded upstream.
  # Clients opt in by pointing at the tunnel address (the Mac via `DNS =` in its
  # tunnel config), so nothing resolves differently when the VPN is down.
  services.dnsmasq = {
    enable = true;
    settings = {
      interface = tunnel.iface;

      # Bind the named interface rather than the wildcard. Without this dnsmasq
      # binds 0.0.0.0 and merely filters by interface, so anything that bypasses
      # the filter reaches a live socket on the public IP — and an open resolver
      # on the internet gets conscripted into DNS amplification attacks.
      bind-interfaces = true;

      address = [ "/vpn/${tunnel.addr}" ];
      server = [
        "1.1.1.1"
        "9.9.9.9"
      ];

      # Never read /etc/resolv.conf for upstreams. If this host's own resolver is
      # ever pointed here, inheriting it would make dnsmasq forward to itself — an
      # infinite loop that presents as "DNS is just broken".
      no-resolv = true;

      # Don't forward junk upstream: unqualified single-label names, and reverse
      # lookups for RFC1918 space that public resolvers can't answer.
      domain-needed = true;
      bogus-priv = true;

      cache-size = 1000;
    };
  };

  # Tunnel-only. DNS needs TCP as well as UDP — responses larger than 512 bytes
  # fall back to it.
  networking.firewall.interfaces.${tunnel.iface} = {
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [ 53 ];
  };
}
