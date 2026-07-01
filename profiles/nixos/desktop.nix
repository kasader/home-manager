_: {
  # Workstation profile: a graphical Hyprland/Wayland session plus audio. Imported
  # by hosts that want a desktop (ramiel); a headless host imports only
  # profiles/nixos/base.nix and gets none of this. The custom.* options below are
  # declared by the modules/nixos registry (pulled in by base).
  #
  # Fonts are NOT here: they're managed once, cross-platform, by the home-level
  # custom.fonts (modules/home/fonts), enabled in profiles/home/base.nix.
  custom = {
    desktop = {
      wayland.enable = true;
      hyprland.enable = true;
    };
    audio.pipewire.enable = true;
  };
}
