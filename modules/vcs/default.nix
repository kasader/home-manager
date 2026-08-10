{ ... }:
{
  # Version-control tooling. Each tool declares its own custom.vcs.<tool> toggle:
  #   git — the VCS itself plus delta/lfs/filter-repo
  #   ghq — repository organizer that clones into a $GHQ_ROOT/<host>/<owner>/<repo>
  #         tree (and the fish `repo` fzf-jump that depends on it)
  imports = [
    ./git.nix
    ./ghq.nix
  ];
}
