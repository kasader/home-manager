{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.browsers.librewolf;
in
{
  options.custom.browsers.librewolf.enable = lib.mkEnableOption "the LibreWolf browser";

  config = lib.mkIf cfg.enable {
    programs.librewolf = {
      enable = true;

      profiles.default = {
        id = 0;
        isDefault = true;
        # Same Floccus extension as Firefox, so bookmarks sync across both.
        extensions.packages = [ pkgs.nur.repos.rycee.firefox-addons.floccus ];
      };

      # LibreWolf respects enterprise policies; search engines go here rather
      # than in the profile (unlike release Firefox).
      policies = {
        SearchEngines = {
          Name = "Jisho.org";
          URLTemplate = "https://jisho.org/search/{searchTerms}";
          Method = "GET | POST";
          IconURL = "https://assets.jisho.org/assets/favicon-062c4a0240e1e6d72c38aa524742c2d558ee6234497d91dd6b75a182ea823d65.ico";
          Alias = "j";
          Description = "Powerful and easy-to-use online Japanese dictionary with words, kanji and example sentences.";
        };
      };
    };
  };
}
