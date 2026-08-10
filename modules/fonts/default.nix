{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.fonts;
in
{
  options.custom.fonts.enable = lib.mkEnableOption "fonts (coding faces + status-bar glyphs)";

  config = lib.mkIf cfg.enable {
    # Fonts are managed here for *both* platforms — no system-level font module is
    # needed. On Linux fontconfig discovers the packages below; on Darwin
    # home-manager rsyncs them into ~/Library/Fonts/HomeManager (a symlink there
    # isn't picked up by macOS), so the same package list covers both.
    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      # Coding faces.
      iosevka
      source-code-pro
      nerd-fonts.jetbrains-mono

      # Broad Unicode coverage + the glyph fonts a status bar (waybar) renders
      # icons from. Harmless on hosts without a desktop; the user session picks
      # them up via fontconfig.
      noto-fonts
      nerd-fonts.symbols-only
      font-awesome_4
    ];
  };
}
