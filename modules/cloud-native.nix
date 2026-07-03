{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.my.cloud-native.enable = lib.mkEnableOption "Cloud native and DevOps tools";

  config = lib.mkIf config.my.cloud-native.enable {
    home.packages = with pkgs; [
      # IaC
      opentofu
      terragrunt
      # 安全/签名
      cosign
      step-ca
      step-cli
      openbao
      sops
      age
      age-plugin-yubikey
      acloud-toolkit-bin
      # 存储/同步
      rclone
      caddy
      skopeo
      packer
    ];
  };
}
