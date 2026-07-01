{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.vcs.git;
in
{
  options.custom.vcs.git.enable = lib.mkEnableOption "git and related tooling";

  config = lib.mkIf cfg.enable {
    programs = {

      git = {
        enable = true;
        lfs.enable = true;
        settings = {
          user = {
            name = "kasader";
            email = "casada980@gmail.com";
          };
          url = {
            "ssh://git@github.com/" = {
              insteadOf = "https://github.com/";
            };
          };
          push.default = "current";
        };
        ignores = [
          ".DS_Store"
          "*~"
          "**/.claude/settings.local.json"
        ];
      };

      # TODO: Make sure to move to dedicated file.
      delta = {
        enable = true;
        enableGitIntegration = true;
      };

    };

    home.packages = with pkgs; [
      git-filter-repo
      gitlint
    ];
  };
}
