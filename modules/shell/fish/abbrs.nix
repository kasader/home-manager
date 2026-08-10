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

  # nix family — drive the flake's Makefile from anywhere (see `mknix` in functions.nix)
  nrs = "mknix switch"; # rebuild + activate THIS host (auto-detected)
  nrb = "mknix build"; # build THIS host without activating

  e = "$EDITOR";
  c = "clear";
  ls = "ls --color";
}
