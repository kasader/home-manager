{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.languages.python3;
in
{
  options.custom.languages.python3 = {
    enable = lib.mkEnableOption "Python ambient env (user base / caches / uv tool bin) + optional global toolchain";
    installToolchain = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install a global Python interpreter + uv as a fallback for use outside project dev-shells.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Ambient location config, NOT the toolchain — read by whatever python/pip/uv
    # is on PATH (the global fallback below, or a project dev-shell's). PYTHONUSERBASE
    # and UV_TOOL_BIN_DIR both route installed console scripts into ~/.local/bin
    # (already on sessionPath), so `pip install --user` and `uv tool install` binaries
    # are runnable with no dedicated PATH entry — the same scheme as GOBIN / CARGO_INSTALL_ROOT.
    home.sessionVariables = {
      PYTHONUSERBASE = "${config.home.homeDirectory}/.local";
      UV_TOOL_BIN_DIR = "${config.home.homeDirectory}/.local/bin";
      PIP_CACHE_DIR = "${config.xdg.cacheHome}/pip";
      UV_CACHE_DIR = "${config.xdg.cacheHome}/uv";
    };

    # Fallback toolchain for ad-hoc use; a project's dev-shell shadows this when
    # you direnv into it. uv covers ephemeral runs (`uvx`) and tool installs,
    # replacing the pipx that used to come from Homebrew.
    home.packages = lib.mkIf cfg.installToolchain [
      pkgs.python3
      pkgs.uv
    ];
  };
}
