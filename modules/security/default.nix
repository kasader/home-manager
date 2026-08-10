{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.security;
in
{
  # Local security tooling. The tools only; secrets/keys live in each tool's own
  # store (~/.config/keepassxc, the YubiKey itself), never in Nix or git.
  options.custom.security.enable = lib.mkEnableOption "local security tooling (password manager, YubiKey)";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      keepassxc
      yubikey-manager
    ];
  };
}
