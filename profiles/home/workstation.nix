{ config, pkgs, ... }:
{
  # Everything that presumes a personal workstation: a graphical session, dev
  # toolchains, cloud accounts, media, toys.
  imports = [ ../../modules/home ];

  custom = {
    fonts.enable = true;
    fun.enable = true;
    media.enable = true;
    security.enable = true;
    services.syncthing.enable = true;
    terminal.ghostty.enable = true;
    cloud = {
      aws.enable = true;
      gcp.enable = true;
      oci.enable = true;
    };
    languages = {
      go.enable = true;
      rust.enable = true;
      python3.enable = true;
    };
  };

  home = {
    packages = with pkgs; [
      aria2
      colordiff
      gh
      graphviz
      hugo
      icdiff
      nixfmt
      nmap
      shfmt
      socat
      stylua
      universal-ctags

      # TODO: Add Soulseek server-client (at some point...)
      # https://github.com/slskd/slskd/

      # TODO: Good OCR for JPN something?
      # tesseract
    ];

    # Work tree, on the machines that do the work.
    sessionVariables.DIARKIS_PATH = "${config.home.homeDirectory}/diarkis";
  };
}
