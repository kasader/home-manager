{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.cloud;
in
{
  # Cloud provider CLIs. Each toggle installs only the *tool*. Credentials are
  # never managed here — they're produced by the CLI's own `auth`/`session`
  # login flow, live in the provider's local cache (~/.config/gcloud, ~/.aws,
  # ~/.oci) and stay out of Nix and git. They're regenerable, so losing one just
  # means re-authenticating; there's nothing to back up. Prefer short-lived
  # identity auth (`gcloud auth login`, `aws sso login`, `oci session ...`) over
  # long-lived key files.
  options.custom.cloud = {
    gcp.enable = lib.mkEnableOption "Google Cloud CLI (gcloud, gsutil)";
    aws.enable = lib.mkEnableOption "AWS CLI v2";
    oci.enable = lib.mkEnableOption "Oracle Cloud Infrastructure CLI";
  };

  config = lib.mkMerge [
    # google-cloud-sdk puts gcloud/gsutil straight on PATH — unlike the
    # hand-installed SDK under ~/.local/share, there's no path.fish.inc to source.
    # Components have to be baked in here: `gcloud components install` can't write
    # into the read-only store path. gke-gcloud-auth-plugin is what kubectl >= 1.26
    # shells out to for GKE clusters, so `get-credentials` produces a usable context.
    (lib.mkIf cfg.gcp.enable {
      home.packages = [
        (pkgs.google-cloud-sdk.withExtraComponents [
          pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin
        ])
      ];

      # Fish abbrvs.
      programs.fish.shellAbbrs = {
        gclist = "gcloud config configurations list";
        gcact = "gcloud config configuration activate";
      };
    })

    (lib.mkIf cfg.aws.enable {
      home.packages = [ pkgs.awscli2 ];
    })

    (lib.mkIf cfg.oci.enable {
      home.packages = [ pkgs.oci-cli ];
    })
  ];
}
