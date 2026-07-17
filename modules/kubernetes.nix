{
  config,
  lib,
  pkgs,
  ...
}:

let
  # 独立安装 kubectl，因此移除 minikube 提供的同名快捷链接，
  # 避免 Home Manager 合并 profile 时发生路径冲突。
  minikubeWithoutKubectl = pkgs.minikube.overrideAttrs (oldAttrs: {
    postInstall = (oldAttrs.postInstall or "") + ''
      rm -f "$out/bin/kubectl"
    '';
  });
in
{
  options.my.kubernetes.enable = lib.mkEnableOption "Kubernetes tools";

  config = lib.mkIf config.my.kubernetes.enable {
    home.packages = with pkgs; [
      kubectl
      kubernetes-helm
      kind
      minikubeWithoutKubectl
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
