{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}:
let
  cfg = config.custom.media;
in
{
  # Media playback and processing CLIs.
  options.custom.media.enable = lib.mkEnableOption "media playback / processing (mpv, ffmpeg)";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      ffmpeg

      # CLI player; the `iina` cask is the GUI front-end over the same engine.
      #
      # youtubeSupport pulls yt-dlp, which since 26.05 depends on deno and so on
      # rusty-v8 ... and rusty-v8 is not a fixed-output fetch, it compiles V8. That
      # closure is cached for x86_64-linux but not for aarch64-darwin, so on macOS
      # the default mpv means compiling V8 locally (hours, tens of GB of scratch).
      # Linux keeps the full-fat mpv; drop this branch if darwin cache coverage
      # improves.
      (if isDarwin then mpv.override { youtubeSupport = false; } else mpv)
    ];
  };
}
