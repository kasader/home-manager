{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}:
let
  cfg = config.custom.terminal.ghostty;
in
{
  options.custom.terminal.ghostty.enable = lib.mkEnableOption "Ghostty terminal emulator";

  config = lib.mkIf cfg.enable {
    programs.ghostty = {
      enable = true;

      # nixpkgs' ghostty is marked broken on Darwin (the macOS app needs an Xcode/Swift
      # toolchain Nix can't drive), so there we manage config declaratively but install
      # Ghostty.app out-of-band — `brew install --cask ghostty` or the official DMG.
      # On Linux the package builds normally.
      package = if isDarwin then null else pkgs.ghostty;

      enableFishIntegration = true;

      # Ghostty ships hundreds of built-in themes; swap on the fly with `ghostty
      # +list-themes` (live preview) or by editing this line and rebuilding.
      settings = {
        theme = "catppuccin-mocha";
        font-family = "JetBrainsMono Nerd Font";
        font-size = 14;
      };
    };
  };
}
