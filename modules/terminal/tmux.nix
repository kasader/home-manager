{ config, lib, ... }:
let
  cfg = config.custom.terminal.tmux;
in
{
  options.custom.terminal.tmux.enable = lib.mkEnableOption "tmux terminal multiplexer";

  config = lib.mkIf cfg.enable {
    programs.tmux = {
      enable = true;

      # Enables mouse support
      mouse = true;

      keyMode = "vi";

      extraConfig = ''
        # Split panes with \ (horizontal) and - (vertical)
        bind \\ split-window -h
        bind - split-window -v
        unbind '"'
        unbind %

        # Reload config
        bind r source-file ${config.xdg.configHome}/tmux/tmux.conf

        # Switch panes with Alt-arrow, no prefix
        bind -n M-Left select-pane -L
        bind -n M-Right select-pane -R
        bind -n M-Up select-pane -U
        bind -n M-Down select-pane -D

        bind -n C-w choose-tree -Z -w
        bind -n M-BSpace kill-pane
      '';
    };
  };
}
