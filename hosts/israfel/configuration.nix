{ ... }:
{
  # macOS system entry for israfel (nix-darwin). Composes the darwin system
  # profile; the home side is wired in flake.nix via integrated home-manager
  # (which imports ./home.nix). Mirrors hosts/ramiel/configuration.nix.
  imports = [
    ../../profiles/darwin/base.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  # Host-specific Homebrew lists. The enable + onActivation policy is baseline
  # (profiles/darwin/base.nix); israfel brings its own taps and casks.
  homebrew = {
    # Taps required by the casks below; core casks (homebrew/cask) need none.
    taps = [
      "nikitabobko/tap" # aerospace
      "isen-ng/dotnet-sdk-versions" # dotnet-sdk6*
    ];

    casks = [
      # "aerospace"
      "calibre"
      "ghostty"
      "handbrake-app"
      "iina"
      "librewolf"
      "meld"
      "orbstack"
      "stats"
    ];

    brews = [ ]; # Phase 2: migrate `brew leaves` here incrementally.
  };

  # Used for backwards compatibility; read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}
