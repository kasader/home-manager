{ config, lib, ... }:
let
  cfg = config.custom.shell.fzf;
in
{
  options.custom.shell.fzf.enable = lib.mkEnableOption "fzf fuzzy finder";

  config = lib.mkIf cfg.enable {
    programs.fzf = {
      enable = true;

      # TODO: Insert other useful features, etc.

      defaultCommand = "rg --files --hidden --glob=!.git/";
    };
  };
}
