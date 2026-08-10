{ pkgs, ... }:
{
  # ramiel's graphical session: Hyprland on Wayland, plus audio. This is the only
  # host with a screen attached, so none of it is shared.

  programs.hyprland.enable = true;

  # programs.waybar.enable installs waybar, so no separate package entry.
  programs.waybar.enable = true;

  # Keyboard layout for the graphical session (also read by XWayland/console).
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  environment.systemPackages = with pkgs; [
    kitty # the terminal stock Hyprland keybinds launch (Super+Q)
    wl-clipboard # wl-copy / wl-paste
    cliphist # clipboard history
    wev # Wayland event viewer — inspect input events / keysyms
  ];

  # Hint Electron/Chromium apps to render through native Wayland, not XWayland.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # rtkit lets PipeWire acquire realtime priority — optional but recommended.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # jack.enable = true; # uncomment for JACK applications
  };

  # TODO: application launcher (rofi / wofi / bemenu) — undecided; add here.
}
