{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.my.desktop.enable = lib.mkEnableOption "Desktop GUI applications";

  config = lib.mkIf config.my.desktop.enable {
    home.packages = with pkgs; [
      feishu
      sourcegit
      # 自打包
      dbeaver-ue-bin
      dbeaver-te-bin
    ];
  };
}
