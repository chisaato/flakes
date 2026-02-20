{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.my.misc.enable = lib.mkEnableOption "Miscellaneous CLI tools" // {
    default = true;
  };

  config = lib.mkIf config.my.misc.enable {
    home.packages = with pkgs; [
      gh
      act
      just
      just-lsp
      q
      yq-go
      tokei
      gdu
      pixi
      devbox
      uv
      ruby
      etcd
      ddev
      crc
      chezmoi
      # 网络工具
      wgcf
      wireproxy
      usque
      # 其他
      bento4
      apktool
      apksigner
      payload-dumper-go
      xwin
      yaml-language-server
      openapi-generator-cli
    ];
  };
}
