_: {
  # Server profile: what every always-on headless host gets, alongside
  # profiles/nixos/base.nix. The desktop counterpart is profiles/nixos/desktop.nix.
  #
  # WireGuard lives here rather than in a host file because every server is
  # expected to join the VPN — that's the point of it. What differs per machine
  # (tunnel address, key location, peer list) has no default and must be supplied
  # by the host, so importing this profile without configuring them is an
  # evaluation error rather than a silently broken tunnel.
  #
  # Services that only the edge box runs (reverse proxy, Kavita, the Hugo site)
  # deliberately do NOT belong here — they go in hosts/nixbox/.
  custom.services.wireguard.enable = true;
}
