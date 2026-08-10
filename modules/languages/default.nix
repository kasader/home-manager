{ ... }:
{
  # Per-language home modules. Each declares its own `custom.languages.<lang>`
  # toggle and sets only *ambient* config (cache/install locations on env +
  # an optional global fallback toolchain) — never a project's pinned toolchain,
  # which belongs in that project's dev-shell.
  imports = [
    ./go.nix
    ./rust.nix
    ./python3.nix
  ];
}
