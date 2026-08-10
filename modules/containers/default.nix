{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}:

let
  cfg = config.custom.containers;
in
{
  options.custom.containers.enable = lib.mkEnableOption "container tooling (Podman, lazydocker, dive)";

  config = lib.mkIf cfg.enable {
    # Cross-platform container client tooling. The engine is platform specific:
    # on Darwin it's OrbStack; on Linux we run rootless Podman.
    home = {
      packages =
        with pkgs;
        [
          lazydocker # container TUI
          dive # inspect image layers
        ]
        # `podman` itself is added by `services.podman` below; only the extras here.
        ++ lib.optionals (!isDarwin) [
          podman-compose
        ]
        ++ lib.optionals isDarwin [
          # OrbStack (macOS container / Linux-VM engine) currently ships via the
          # Homebrew cask in hosts/israfel/configuration.nix. Uncomment to move it
          # under nix and drop the cask — completes the brew→nix migration.
          # orbstack
        ];

      shellAliases = lib.mkIf (!isDarwin) {
        docker = "podman";
        docker-compose = "podman-compose";
      };

      # For tools that need the Docker REST API (testcontainers, the docker CLI's
      # remote mode, etc.), point them at Podman's rootless socket. The socket is
      # socket-activated, so enable it once per machine:
      #   systemctl --user enable --now podman.socket
      sessionVariables = lib.mkIf (!isDarwin) {
        DOCKER_HOST = "unix://\${XDG_RUNTIME_DIR}/podman/podman.sock";
      };
    };

    services.podman = lib.mkIf (!isDarwin) {
      enable = true;
      settings.registries.search = [
        "docker.io"
        "ghcr.io"
      ];
    };
  };
}
