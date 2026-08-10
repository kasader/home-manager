{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.vcs.ghq;
in
{
  options.custom.vcs.ghq.enable =
    lib.mkEnableOption "ghq repository manager (github.com/<org>/<repo> layout)";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.ghq ];

    # ghq clones every repo to $GHQ_ROOT/<host>/<owner>/<repo>, so origin and
    # ownership are encoded in the path. For Go work the path also mirrors the
    # module path, which makes "where does this live?" answerable from memory.
    home.sessionVariables.GHQ_ROOT = "${config.home.homeDirectory}/src";

    # fzf-jump to any cloned repo. Lives here rather than in the fish module
    # because it is meaningless without ghq; it merges into the fish config
    # home-manager generates (which is itself gated on custom.shell.enable).
    programs.fish.functions.repo = # fish
      ''
        set -l dir (ghq list --full-path | fzf --query "$argv" --select-1 --exit-0)
        if test -n "$dir"
          cd "$dir"
        end
      '';

    programs.fish.shellAbbrs = {
      gq = "ghq get -p"; # clone (over ssh, via git insteadOf) into the tree
      gql = "ghq list";
      ghc = "ghq clone";
      ghl = "ghq list";
      ghrm = "ghq rm";
      ghcr = "ghq create";
    };
  };
}
