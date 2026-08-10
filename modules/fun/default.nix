{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.fun;
in
{
  # Terminal toys and typing games. Split out so headless/server profiles can
  # leave them off — enabled in the base profile for now since both hosts are
  # personal workstations.
  options.custom.fun.enable = lib.mkEnableOption "terminal toys and typing games";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # toys
      cowsay
      lolcat
      figlet # funny text guy
      fortune
      sl # steam engine
      asciiquarium
      cmatrix
      boxes

      # typing tests
      ttyper
      typioca
      gtypist
    ];
  };
}
