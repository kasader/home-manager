# fish abbreviations; plain data, imported by ./default.nix. See
# https://github.com/donovanglover/nix-config/blob/master/home/fish.nix for ideas.
{
  # git family
  g = "git";
  ga = "git add";
  gcm = "git commit -m";
  gcnm = "git commit -n -m";
  gd = "git diff";
  gds = "git diff --staged";
  gs = "git status";
  gp = "git push";
  gpf = "git push --force";
  gcnv = "git commit --no-verify -m";
  lg = "lazygit";

  # ghq family
  ghc = "ghq clone";
  ghl = "ghq list";
  ghrm = "ghq rm";
  ghcr = "ghq create";

  # go family
  glci = "golangci-lint run ./...";

  # gcloud family
  gclist = "gcloud config configurations list";
  gcact = "gcloud config configuration activate";

  # k8s family
  k = "kubectl";
  kctx = "kubectx";
  kns = "kubens";

  # nix family — drive the flake's Makefile from anywhere (see `mknix` in functions.nix)
  nrs = "mknix switch"; # rebuild + activate THIS host (auto-detected)
  nrb = "mknix build"; # build THIS host without activating

  e = "$EDITOR";
  c = "clear";
  ls = "ls --color";
}
