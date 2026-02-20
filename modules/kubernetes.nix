{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.my.kubernetes.enable = lib.mkEnableOption "Kubernetes tools";

  config = lib.mkIf config.my.kubernetes.enable {
    home.packages = with pkgs; [
      kubectl
      kubernetes-helm
      kind
      minikube
      argocd
      velero
      istioctl
      cilium-cli
      hubble
      kn
      func
      kubevela
      skaffold
      telepresence2
      helm-ls
      chart-testing
      # 自打包
      chart-releaser
    ];
  };
}
