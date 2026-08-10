{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.languages.rust;
in
{
  options.custom.languages.rust = {
    enable = lib.mkEnableOption "Rust ambient env (cargo home/install root) + optional global toolchain";
    installToolchain = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install a global Rust toolchain as a fallback for use outside project dev-shells.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Ambient location config, NOT the toolchain — valid no matter where cargo
    # comes from (the nix fallback below, or a dev-shell). CARGO_INSTALL_ROOT puts
    # `cargo install` binaries in ~/.local/bin (already on sessionPath). No
    # RUSTUP_HOME: the fallback is nix-provided, not rustup-managed.
    home.sessionVariables = {
      CARGO_HOME = "${config.xdg.dataHome}/cargo";
      CARGO_INSTALL_ROOT = "${config.home.homeDirectory}/.local";
    };

    # Fallback toolchain for ad-hoc use; a project's dev-shell shadows this when
    # you direnv into it.
    home.packages = lib.mkIf cfg.installToolchain [
      pkgs.cargo
      pkgs.rustc
      pkgs.clippy
      pkgs.rustfmt
      pkgs.rust-analyzer
    ];
  };
}
