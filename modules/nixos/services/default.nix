{ ... }:
{
  # Server-service registry. Like the rest of modules/nixos, importing here only
  # *declares* the custom.services.* options — profiles and hosts turn them on.
  imports = [
    ./wireguard.nix
  ];
}
