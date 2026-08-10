{
  config,
  lib,
  pkgs,
  isDarwin,
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
      # TODO: Fix all of this stuff w/ the package and configPath (currently stopgap per
      # the migration to nix-26.05).
      #
      # Mozilla's official prebuilt binary is the low-risk choice on macOS; the
      # source build is the cached standard on Linux. This branch is load-bearing:
      # plain `firefox` on darwin is a from-source build that nixpkgs does not
      # cache, so it compiles Firefox (hours, tens of GB of scratch) instead of
      # fetching it. firefox-bin is substitutable from cache.nixos.org.
      package = if isDarwin then pkgs.firefox-bin else pkgs.firefox;

      # HM 26.05 moved the *Linux* default to $XDG_CONFIG_HOME/mozilla/firefox.
      # Pinned to the legacy path because adopting the new one is a data
      # migration, not a config change: ~/.mozilla/firefox must be moved by hand
      # and native messaging hosts don't follow.
      #
      # Linux only — darwin has its own default ("Library/Application Support/
      # Firefox") and never had a stateVersion-gated change. Setting this
      # unconditionally would relocate the macOS profile to a Linux path.
      configPath = lib.mkIf (!isDarwin) ".mozilla/firefox";

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
