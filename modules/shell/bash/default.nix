{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Bash is kept purely as a script interpreter — no `programs.bash`, so none of
  # its startup files (.bashrc/.bash_profile/.profile) get written to $HOME.
  # Bash has no ZDOTDIR, so those files can't be relocated like zsh's; not
  # managing bash config at all is the only way to keep them out of $HOME.
  # Scripts run via their shebang and don't read interactive config anyway.
  config = lib.mkIf config.custom.shell.enable {
    home.packages = [ pkgs.bash ];
  };
}
