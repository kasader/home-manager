{
  description = "Lua development environment.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.lua5_4
            pkgs.luarocks
            pkgs.lua-language-server
            pkgs.stylua
            pkgs.luaPackages.luacheck
          ];

          shellHook = ''
            echo "lua dev shell ready"
          '';
        };
      }
    );
}
