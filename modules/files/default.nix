{ ... }:
{
  # File-management tooling. Each tool declares its own custom.files.<tool>
  # toggle; room here for more (rangers, du tools, …) later.
  imports = [
    ./yazi.nix
  ];
}
