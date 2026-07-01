{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.browsers.firefox;
in
{
  options.custom.browsers.firefox.enable = lib.mkEnableOption "the Firefox browser";

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      # Mozilla's official prebuilt binary is the low-risk choice on macOS; the
      # source build is the cached standard on Linux.
      package = pkgs.firefox;

      # Search engines live in the profile (search.json.mozlz4), not in policies:
      # the SearchEngines policy is ESR-only and is ignored by release Firefox.
      profiles.default = {
        id = 0;
        isDefault = true;

        # Floccus — cross-browser bookmark sync. Nix installs the extension only;
        # the sync backend (Git/WebDAV) is configured once in Floccus's own UI.
        extensions.packages = [ pkgs.nur.repos.rycee.firefox-addons.floccus ];

        search = {
          # Required: Firefox re-links search config on every launch, so Home
          # Manager won't overwrite it unless forced. Note this means HM now owns
          # the search config and will drop engines added manually in the UI.
          force = true;
          engines = {
            "Jisho" = {
              urls = [ { template = "https://jisho.org/search/{searchTerms}"; } ];
              iconMapObj."16" =
                "https://assets.jisho.org/assets/favicon-062c4a0240e1e6d72c38aa524742c2d558ee6234497d91dd6b75a182ea823d65.ico";
              definedAliases = [ "@j" ];
            };
            "DeepL" = {
              urls = [ { template = "https://www.deepl.com/translator?share=generic#ja/en-us/{searchTerms}"; } ];
              iconMapObj."16" = "https://www.deepl.com/favicon.ico";
              definedAliases = [ "@d" ];
            };
            "youtube" = {
              urls = [ { template = "https://www.youtube.com/results?search_query={searchTerms}"; } ];
              iconMapObj."16" = "https://www.youtube.com/favicon.ico";
              definedAliases = [ "@y" ];
            };
          };
        };
      };
    };
  };
}
