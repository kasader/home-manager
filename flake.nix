{
  description = "My Nix home-manager configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs"; # Stating *.follows = 'nixpkgs'; indicates that
      # the home-manager input is DEPENDENT on nixpkgs. I.e, an import DAG creation.
    };

    # macOS system layer. Release branch pinned to match nixpkgs/home-manager
    # (26.05). follows = nixpkgs keeps the whole tree on one nixpkgs.
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix User Repository — provides rycee.firefox-addons for declarative browser extensions.
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secret management. Secrets are age-encrypted to each host's SSH *host* key
    # (plus my personal key, so I can still edit them), committed as ciphertext,
    # and decrypted to /run/agenix at activation — never into the world-readable
    # Nix store. Recipients live in ./secrets.nix, which the `agenix` CLI reads;
    # the flake itself never evaluates that file.
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Pre-commit hook manager. Wires fmt/lint/secret checks into both
    # `nix flake check` and a devShell-installed git hook.
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      nur,
      agenix,
      git-hooks,
      ...
    }:
    let
      inherit (nixpkgs) lib;

      # The two systems we build for: israfel (macOS) and ramiel (NixOS).
      # `checks`/`devShells` are instantiated per-system; the host configs
      # below pin their own platform independently.
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];
      forAllSystems =
        f:
        lib.genAttrs systems (
          system:
          f {
            inherit system;
            pkgs = nixpkgs.legacyPackages.${system};
          }
        );

      # Host factory. Every host uses the same two-tier integration: one
      # `{nixos,darwin}-rebuild switch` builds system + home together, with the
      # portable home core (profiles/home/*) reused verbatim via the host's
      # home.nix. Home is managed only through this integration — there is no
      # standalone homeConfiguration, so ~/.nix-profile is never owned by a
      # second activation path (which is what broke the login shell before).
      #
      # `isDarwin` selects the system builder, the matching home-manager module,
      # and the platform flag handed to home modules via specialArgs (they branch
      # on it without reading `pkgs`, which would be infinite recursion). Each
      # host's configuration.nix owns its own nixpkgs.hostPlatform.
      mkHost =
        { isDarwin, hostDir }:
        let
          builder = if isDarwin then nix-darwin.lib.darwinSystem else lib.nixosSystem;
          hmModule =
            if isDarwin then
              home-manager.darwinModules.home-manager
            else
              home-manager.nixosModules.home-manager;
        in
        builder {
          modules = [
            (hostDir + "/configuration.nix")
            hmModule
          ]
          # agenix, NixOS hosts only for now: nixbox is the only machine with
          # secrets, and leaving israfel's module list untouched keeps its
          # derivation byte-identical. agenix.darwinModules.default exists if
          # macOS ever needs secrets too.
          ++ lib.optional (!isDarwin) agenix.nixosModules.default
          ++ [
            {
              nixpkgs.config.allowUnfree = true;
              # NUR overlay on the *system* pkgs so the integrated HM (which uses
              # useGlobalPkgs) can resolve rycee.firefox-addons.
              nixpkgs.overlays = [ nur.overlays.default ];

              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit isDarwin; };
                users.kasada.imports = [ (hostDir + "/home.nix") ];
              };
            }
          ];
        };
    in
    {
      nixosConfigurations.ramiel = mkHost {
        isDarwin = false;
        hostDir = ./hosts/ramiel;
      };

      nixosConfigurations.nixbox = mkHost {
        isDarwin = false;
        hostDir = ./hosts/nixbox;
      };

      nixosConfigurations.nixos = mkHost {
        isDarwin = false;
        hostDir = ./hosts/nixos;
      };

      darwinConfigurations.israfel = mkHost {
        isDarwin = true;
        hostDir = ./hosts/israfel;
      };

      # Pre-commit gate. `nix flake check` builds this (running every hook in a
      # sandbox); `nix develop` installs it as the repo's git pre-commit hook.
      checks = forAllSystems (
        { system, pkgs }:
        let
          # The hardware configs are generated by nixos-generate-config ("Do not
          # modify"), so the linters leave them alone. excludes are regexes (the
          # pre-commit file list); statix walks the tree itself, so it needs its
          # own glob `settings.ignore` as well.
          skipRegexes = [
            "^hosts/ramiel/hardware-configuration\\.nix$"
            "^hosts/nixbox/hardware-configuration\\.nix$"
            "^hosts/nixos/hardware-configuration\\.nix$"
          ];
          skipGlobs = [ "**/hardware-configuration.nix" ];
        in
        {
          pre-commit = git-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixfmt-rfc-style = {
                enable = true; # formatting — matches `make fmt`
                excludes = skipRegexes;
              };
              deadnix = {
                enable = true; # unused bindings / dead code
                excludes = skipRegexes;
              };
              statix = {
                enable = true; # Nix anti-patterns
                excludes = skipRegexes;
                settings.ignore = skipGlobs;
              };

              # This git-hooks.nix has no built-in gitleaks hook (only ripsecrets/
              # trufflehog), so define it directly. Like flake-eval below it needs
              # the real git tree, which is absent from the sandbox that builds
              # this check, so guard on it. Keying on a build-env var like
              # NIX_BUILD_TOP would wrongly also skip inside `nix develop`/direnv
              # shells (which set it) — silently bypassing the scan on real
              # commits made from a dev shell. Absence of a repo is the only
              # signal unique to the sandbox.
              gitleaks = {
                enable = true;
                name = "gitleaks";
                description = "Scan staged changes for committed secrets";
                entry = toString (
                  pkgs.writeShellScript "pre-commit-gitleaks" ''
                    git rev-parse --git-dir >/dev/null 2>&1 || exit 0
                    exec ${pkgs.gitleaks}/bin/gitleaks git --staged --redact --verbose .
                  ''
                );
                pass_filenames = false;
              };

              # Full flake eval so a commit can't break the host configs. This
              # runs `nix flake check` itself, so it must NOT run inside the
              # sandbox that builds *this* check — there's no `nix` on PATH and no
              # network there, and it would recurse. `nix` being absent is the one
              # signal unique to the sandbox: a real commit (plain shell or
              # nix develop/direnv) always has it, the build sandbox never does.
              # (NIX_BUILD_TOP is the trap — it's also set inside dev shells.)
              flake-eval = {
                enable = true;
                name = "nix flake check";
                entry = toString (
                  pkgs.writeShellScript "pre-commit-flake-eval" ''
                    command -v nix >/dev/null 2>&1 || exit 0
                    exec nix flake check --no-build
                  ''
                );
                pass_filenames = false;
              };
            };
          };
        }
      );

      devShells = forAllSystems (
        { system, pkgs }:
        {
          default = pkgs.mkShell {
            inherit (self.checks.${system}.pre-commit) shellHook;
            buildInputs = self.checks.${system}.pre-commit.enabledPackages;
          };
        }
      );

      # devShell templates for languages the-nix-way/dev-templates doesn't
      # cover. `devinit lua` scaffolds this via `nix flake init -t $NIX_FLAKE#lua`.
      templates.lua = {
        path = ./templates/lua;
        description = "Lua devShell: lua, luarocks, lua-language-server, stylua, luacheck";
      };
    };
}
