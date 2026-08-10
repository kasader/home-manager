{ config, lib, ... }:
{
  config = lib.mkIf config.custom.shell.enable {
    programs.starship = {
      enable = true;

      enableFishIntegration = true;
      enableZshIntegration = true;
      enableTransience = true;

      # TODO: Presets will be added in the next release of home-manager (I think).
      # presets = [ "nerd-font-symbols" ];

      settings = {
        add_newline = false;
      };
    };
  };
}
