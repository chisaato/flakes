{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.my.container.enable = lib.mkEnableOption "Container and image tools";

  config = lib.mkIf config.my.container.enable {
    home.packages = with pkgs; [
      buildkit
      dive
      pack
    ];
  };
}
