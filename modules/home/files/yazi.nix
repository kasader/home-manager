{ config, lib, ... }:
let
  cfg = config.custom.files.yazi;
in
{
  options.custom.files.yazi.enable = lib.mkEnableOption "yazi file manager";

  config = lib.mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      enableFishIntegration = true;

      shellWrapperName = "yy";
    };
  };
}
