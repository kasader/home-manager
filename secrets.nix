# agenix recipient map. Read by the `agenix` CLI only — the flake never
# evaluates this file, so it defines no options and imports nothing.
#
# Every entry lists the public keys that may decrypt that secret:
#   - the *host* key of each machine that needs it at activation time
#   - my personal key, so I can still `agenix -e` the file later
#
# Host keys come from `ssh-keyscan <host>` (or /etc/ssh/ssh_host_ed25519_key.pub
# on the machine). These are public keys; committing them is expected.
#
# Usage:
#   nix run github:ryantm/agenix -- -e secrets/<name>.age    # create / edit
#   nix run github:ryantm/agenix -- -r                       # rekey after adding a host
let
  # Users
  kasada = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGTzdbcvGlOFncCHcBN91i/JvY1X9YBmj1ZNhbElfv+e sasha@diarkis.io";

  # Hosts
  nixbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBjdRZjNrHS7+RHKNR24Nl6KIqXBcTBXxHzgyb9l7khA";
in
{
  "secrets/wireguard-nixbox-private.age".publicKeys = [
    kasada
    nixbox
  ];

  "secrets/kavita-token.age".publicKeys = [
    kasada
    nixbox
  ];
}
