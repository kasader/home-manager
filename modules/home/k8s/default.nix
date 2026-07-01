{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.k8s;
in
{
  options.custom.k8s.enable = lib.mkEnableOption "Kubernetes tooling";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      kubectl # kubernetes-cli
      kubernetes-helm # helm
      kustomize
      k9s
      kubectx # provides kubectx + kubens
      stern
      minikube
      kubeconform
      kube-linter
      conftest
    ];
  };
}
