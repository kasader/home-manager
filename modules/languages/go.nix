{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.languages.go;
in
{
  options.custom.languages.go = {
    enable = lib.mkEnableOption "Go ambient env (GOPATH/GOBIN) + optional global toolchain";
    installToolchain = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install a global Go toolchain as a fallback for use outside project dev-shells.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Ambient location config, NOT the toolchain — read by whatever `go` is on
    # PATH (the global fallback below, or a project dev-shell's). GOBIN points at
    # ~/.local/bin (already on sessionPath), so `go install` binaries are runnable
    # with no dedicated PATH entry.
    home.sessionVariables = {
      GOPATH = "${config.xdg.dataHome}/go";
      GOBIN = "${config.home.homeDirectory}/.local/bin";
    };

    # Fallback toolchain for ad-hoc use; a project's dev-shell shadows this when
    # you direnv into it.
    home.packages = lib.mkIf cfg.installToolchain [
      pkgs.go
      pkgs.mage # TODO: for required projects (would like to eventually remove dependency).
    ];
  };
}
